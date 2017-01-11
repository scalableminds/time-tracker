Backbone = require("backbone")
moment = require("moment")
Utils = require("utils")
TeamTimeCollection = require("models/team_time_collection")
ViewModel = require("models/viewmodel")
_ = require("underscore")

# #############
# Project ViewModel
#
# Handles the transformation of the general TeamTimeCollection data for the
# 'project' view and serves common view models attributes for this view.
# #############

class ProjectViewModel extends ViewModel

  defaults : ->
    date : moment().startOf("month")
    rows : new Backbone.Collection()
    monthlyTotalHours : 0
    dailyTotalHours : 0
    urlRoot : "project"
    viewTitle : "Project View"
    githubUrl : null


  dataSourceClass : TeamTimeCollection


  transformData : ->

    # reset
    @get("rows").reset([])

    # First group all issues by their repository (aka Project)
    projectIssues = @dataSource.groupBy((timeEntry) ->
      return timeEntry.get("issueReference").project
    )

    # Iterate over all issues ...
    _.each(projectIssues, (timings, repositoryName) =>

      # ... and group by their users
      userProjects = _.groupBy(timings, (timing) ->
        return timing.get("userId")
      )

      # Finally add the days of the month to every project...
      userProjects = _.transform(userProjects,
        (result, project, key) =>
          result[key] = Utils.range(1, @get("date").daysInMonth()).map(
            (day) -> return Utils.sum(
              _.filter(project,
                (project) -> return moment(project.get("dateTime")).date() == day
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
        githubUrl : null
      )

      # Add the daily individual time logs to the collection
      _.each(userProjects, (dailyEntries, userID) =>
        @get("rows").add(
          isHeader : false
          name : @usersCollection.getNameById(userID)
          sum : Utils.sum(dailyEntries)
          dailyTimeEntries : dailyEntries
          githubUrl : "https://github.com/#{@usersCollection.getGithubNameById(userID)}"
        )
      )
    )

module.exports = ProjectViewModel
