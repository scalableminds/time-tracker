_ = require("underscore")
Backbone = require("backbone")
moment = require("moment")
Utils = require("utils")
TeamTimeCollection = require("models/team_time_collection")
ViewModel = require("models/viewmodel")

# #############
# Milestone ViewModel
#
# Handles the transformation of the general TeamTimeCollection data for the
# 'team' view and serves common view models attributes for this view.
# #############

class MilestoneViewModel extends ViewModel

  defaults : ->
    date : moment().startOf("month")
    rows : new Backbone.Collection()
    monthlyTotalHours : 0
    dailyTotalHours : 0
    urlRoot : "milestone"
    viewTitle : "Milestone Report"


  dataSourceClass : TeamTimeCollection

  initialize : (options = {}) ->
    super(options)
    @dataSource.withMilestones = true


  transformData : ->

    # reset
    @get("rows").reset([])

    # First group all issues by their repository (aka Project)
    projects = @dataSource.groupBy((timeEntry) ->
      return timeEntry.get("issueReference").project
    )

    # Iterate over all issues ...
    _.each(projects, (entries, repositoryName) =>

      # ... and group by their users
      projectMilestones = _.groupBy(entries, (entry) ->
        return entry.get("milestone")?.title ? "(none)"
      )

      # Finally add the days of the month to every project...
      projectMilestones = _.transform(projectMilestones,
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
      sumDaily = Utils.range(1, @get("date").daysInMonth()).map((i) -> return Utils.sum(_.values(projectMilestones), i - 1)) #-1 because days start with 1 and arrays with 0
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
      _.each(projectMilestones, (dailyEntries, milestoneTitle) =>
        milestoneId = entries.find((entry) => entry.get("milestone")?.title == milestoneTitle)?.get("milestone").number
        @get("rows").add(
          isHeader : false
          name : milestoneTitle
          sum : Utils.sum(dailyEntries)
          dailyTimeEntries : dailyEntries
          githubUrl : if milestoneId? then "https://github.com/#{repositoryName}/milestone/#{milestoneId}" else ""
        )
      )
    )

module.exports = MilestoneViewModel

