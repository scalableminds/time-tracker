### define
underscore : _
backbone : Backbone
jquery : $
moment : moment
utils: Utils
models/team_time_collection : TeamTimeCollection
models/users_collection : UsersCollection
###

# #############
# Team ViewModel
#
# Handles the transformation of the general TeamTimeCollection data for the
# 'team' view and serves common view models attributes for this view.
# #############

class TeamViewModel extends Backbone.Model

  defaults : ->
    date : moment()
    rows : new Backbone.Collection()
    monthlyTotalHours : 0
    dailyTotalHours : 0
    urlRoot : "team"
    viewTitle : "Team Report"

  dataSourceClass : TeamTimeCollection


  initialize : (options = {}) ->

    if options.date
      @set("date", moment(options.date).startOf("month"))

    @dataSource = new @dataSourceClass()
    @usersCollection = new UsersCollection()


  fetch : =>

    @dataSource.date = @get("date")
    userPromise = @usersCollection.fetch()
    dataPromise = @dataSource.fetch()

    return $.when(userPromise, dataPromise).done(
      =>
        @set {
          monthlyTotalHours: @dataSource.getMonthlyTotalHours()
          dailyTotalHours: @dataSource.getDailyTotalHours()
        }
        @transformData()
        @trigger("sync", @)
    )


  transformData : ->

    # reset
    @get("rows").reset([])

    # Call this after the model is initalized and format the data to fit this view
    # Iterate of every user...
    userIssues = @dataSource.groupBy("userGID")
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
        isHeader : true
        name : @usersCollection.getNameById(user)
        sum : sumTotal
        dailyTimeEntries : sumDaily
      )

      # Add the daily individual time logs to the collection
      _.each(timeEntries, (timeEntry, projectName) =>
        sumCompleteProject = Utils.sum(timeEntry)
        @get("rows").add(
          isHeader : false
          name : projectName
          sum : sumCompleteProject
          dailyTimeEntries : timeEntry
        )
      )
    )



