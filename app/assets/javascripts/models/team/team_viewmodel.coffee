### define
backbone : Backbone
moment : moment
utils: Utils
../team_time_collection : TeamTimeCollection
###

# #############
# Team ViewModel
#
# Handles the transformation of the general TeamTimeCollection data for the
# 'team' view and serves common view models attributes for this view.
# #############

class TeamViewModel extends Backbone.Model

  defaults :
    date : moment()
    rows : new Backbone.Collection()
    monthlyTotalHours : 0
    dailyTotalHours : 0
    urlRoot : "team"


  initialize : (options = {}) ->

    if options.date
      @set("date", moment(options.date).startOf("month"))

    @teamTimeCollection = new TeamTimeCollection(date : @get("date"))
    @listenTo(@teamTimeCollection, "sync", @synced)


  fetch : =>

    @teamTimeCollection.date = @get("date")
    return @teamTimeCollection.fetch().done(
      =>
        @trigger("sync", @)
    )


  synced : ->

    # Make sure we save the server data under a meaningful attribute
    @set {
      monthlyTotalHours: @teamTimeCollection.getMonthlyTotalHours()
      dailyTotalHours: @teamTimeCollection.getDailyTotalHours()
    }

    @transformData()


  transformData : ->

    # reset
    @get("rows").reset([])

    # Call this after the model is initalized and format the data to fit this view
    # Iterate of every user...
    userIssues = @teamTimeCollection.groupBy("userGID")
    _.each(userIssues, (timings, user) =>

      # and group his issue by his repositories (aka projects)
      timeEntries = _.groupBy(timings,
        (timing) -> timing.get("issue").project)

      # Finally add the days of the month to every project...
      timeEntries = _.transform(timeEntries,
        (result, project, key) =>
          result[key] = Utils.range(1, @get("date").daysInMonth()).map(
            (day) -> return Utils.sum(
              _.filter(project,
                (project) -> return moment(project.get("timestamp")).date() == day
              ).map(
                (projectFilterdByDay) -> return projectFilterdByDay.get("duration")
              )
            )
          )
        )

      # Sum up the total amount of hours per day for every user
      sumDaily = Utils.range(1, @get("date").daysInMonth()).map((i) -> return Utils.sum(_.values(timeEntries), i - 1)) #-1 because days start with 1 and arrays with 0
      sumTotal = Utils.sum(sumDaily)

      #Add that shit to the collection as a table 'header' for every user
      @get("rows").add(
        isUserHeader : true
        userName : user
        sumTotal : sumTotal
        sumDaily : sumDaily
      )

      # Add the daily individual time logs to the collection
      _.each(timeEntries, (timeEntry, projectName) =>
        sumCompleteProject = Utils.sum(timeEntry)
        @get("rows").add(
          isUserHeader : false
          projectName : projectName
          sumCompleteProject : sumCompleteProject
          timeEntry : timeEntry
        )
      )
    )





