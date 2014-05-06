### define
backbone : Backbone
moment : moment
utils: Utils
../team_time_collection : TeamTimeCollection
###

# #############
# Project ViewModel
#
# Handles the transformation of the general TeamTimeCollection data for the
# 'project' view and serves common view models attributes for this view.
# #############

class ProjectViewModel extends Backbone.Model

  defaults :
    date : moment()
    rows : new Backbone.Collection()
    monthlyTotalHours : 0
    dailyTotalHours : 0
    urlRoot : "project"
    viewTitle : "Project View"


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

    projectIssues = @teamTimeCollection.groupBy((timeEntry) ->
      return timeEntry.get("issue").project
    )

    _.each(projectIssues, (timings, repositoryName) =>

      userProjects = _.groupBy(timings, (timing) ->
        return timing.get("userGID")
      )

      # Finally add the days of the month to every project...
      userProjects = _.transform(userProjects,
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

      # Sum up the total amount of hours per day for every issue
      sumDaily = Utils.range(1, @get("date").daysInMonth()).map((i) -> return Utils.sum(_.values(userProjects), i - 1)) #-1 because days start with 1 and arrays with 0
      sumTotal = Utils.sum(sumDaily)

      #Add that shit to the collection as a table 'header' for every user
      @get("rows").add(
        isHeader : true
        name : repositoryName
        sum : sumTotal
        dailyTimeEntries : sumDaily
      )

      # Add the daily individual time logs to the collection
      _.each(userProjects, (dailyEntries, userID) =>
        @get("rows").add(
          isHeader : false
          name : userID
          sum : Utils.sum(dailyEntries)
          dailyTimeEntries : dailyEntries
        )
      )
    )


