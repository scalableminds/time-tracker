### define
backbone : backbone
moment : moment
utils : Utils
models/user_time_collection : UserTimeCollection
models/viewmodel : ViewModel
###

# #############
# User ViewModel
#
# Handles the transformation of the general UserTimeModel data for the
# 'me' view and serves common view models attributes for this view.
# #############

class UserViewModel extends ViewModel

  defaults : ->
    date : moment().startOf("month")
    rows : new Backbone.Collection()
    monthlyTotalHours : 0
    dailyTotalHours : 0
    urlRoot : "home"
    viewTitle : "User Report"

  dataSourceClass : UserTimeCollection

  transformData : ->

    # reset
    @get("rows").reset([])

    # First group all issues by their repository (aka Project)
    projectIssues = @dataSource.groupBy((timeEntry) ->
      return timeEntry.get("issue").reference.project
    )

    projectIssues = _.transform(projectIssues,
      (result, issues, key) ->
        result[key] = _.groupBy(issues,
          (timeEntry) ->
            return timeEntry.get("issue").reference.number
        )
    )

    # Finally add the days of the month to every project...
    _.each(projectIssues, (project, repositoryName) =>

      issueGroups = _.map(project,
        (issues) =>
          name : issues[0].get("issue").title
          number : issues[0].get("issue").reference.number
          values : Utils.range(1, @get("date").daysInMonth()).map(
            (day) -> return Utils.sum(
              _.filter(issues,
                (issue) -> return moment(issue.get("dateTime")).date() == day
              ).map(
                (projectFilterdByDay) -> return projectFilterdByDay.get("duration")
              )
            )
          )
        )

      # Sum up the total amount of hours per day for every issue
      sumDaily = Utils.range(1, @get("date").daysInMonth()).map((i) -> return Utils.sum(issueGroups.map((issue) -> issue.values[i - 1]))) #-1 because days start with 1 and arrays with 0
      sumTotal = Utils.sum(sumDaily)

      # Add that shit to the collection as a table 'header' for every user
      @get("rows").add(
        isHeader : true
        name : repositoryName
        sum : sumTotal
        dailyTimeEntries : sumDaily
      )

      # Add the daily individual time logs to the collection
      _.each(issueGroups, (group) =>
        {name, number, values} = group
        @get("rows").add(
          isHeader : false
          name : "#{number} #{name}"
          sum : Utils.sum(values)
          dailyTimeEntries : values
        )
      )
    )


