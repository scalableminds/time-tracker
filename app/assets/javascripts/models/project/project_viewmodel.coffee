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

    allTimeEntries= [].concat(@teamTimeCollection.pluck("times")...)
    allTimeEntries = _.groupBy(allTimeEntries, (timeEntry) ->
      return timeEntry.issue.project
    )

    _.each(allTimeEntries, (timings, repositoryName) =>

      dailyEntriesPerUser = @teamTimeCollection.map((user) =>

        # and group his issue by his repositories (aka projects)
        userIssues = _.filter(user.get("times"), (timeEntry) ->
          timeEntry.issue.project == repositoryName
        )
        return Utils.range(1, @get("date").daysInMonth()).map(
          (day) -> return Utils.sum(
            _.map(userIssues, (issue) ->
              if moment(issue.timestamp).date() == day
                return issue.duration
              else
                return 0
            )
          )
        )
      )


      # Sum up the total amount of hours per day for every issue
      sumDaily = Utils.range(1, @get("date").daysInMonth()).map((i) -> return Utils.sum(dailyEntriesPerUser, i - 1)) #-1 because days start with 1 and arrays with 0
      sumTotal = Utils.sum(sumDaily)

      #Add that shit to the collection as a table 'header' for every user
      @get("rows").add(
        isUserHeader : true
        userName : repositoryName
        sumTotal : sumTotal
        sumDaily : sumDaily
      )

      # Add the daily individual time logs to the collection
      @teamTimeCollection.forEach((user, i) =>
        @get("rows").add(
          isUserHeader : false
          projectName : user.get("name")
          sumCompleteProject : Utils.sum(dailyEntriesPerUser[i])
          timeEntry : dailyEntriesPerUser[i]
        )
      )
    )


