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
    for repositoryName in Object.keys(projects)
      projectEntries = projects[repositoryName]

      # ... group by their milestones ...
      projectMilestones = _.groupBy(projectEntries, (entry) ->
        return entry.get("milestone")?.title ? "(none)"
      )

      for milestoneTitle in Object.keys(projectMilestones)
        projectMilestoneEntries = projectMilestones[milestoneTitle]
        milestoneId = projectMilestoneEntries[0]?.get("milestone")?.number

        # ... group by their milestones ...
        userProjectMilestones = _.groupBy(projectMilestoneEntries, (entry) -> entry.get("userId"))

        # Finally add the days of the month to every project...
        userProjectMilestones = _.transform(userProjectMilestones,
          (result, entries, key) =>
            result[key] = Utils.range(1, @get("date").daysInMonth()).map(
              (day) -> return Utils.sum(
                entries
                  .filter((entry) -> return moment(entry.get("dateTime")).date() == day)
                  .map((projectFilterdByDay) -> return projectFilterdByDay.get("duration"))
              )
            )
        )

        # Sum up the total amount of hours per day for every issue
        sumDaily = Utils.range(1, @get("date").daysInMonth())
          #-1 because days start with 1 and arrays with 0
          .map((i) -> return Utils.sum(_.values(userProjectMilestones), i - 1))
        sumTotal = Utils.sum(sumDaily)

        # Add that shit to the collection as a table 'header' for every user
        @get("rows").add(
          isHeader : true
          name : "#{repositoryName}<br />&rsaquo; #{milestoneTitle}"
          sum : sumTotal
          dailyTimeEntries : sumDaily
          githubUrl : if milestoneId?
            "https://github.com/#{repositoryName}/milestone/#{milestoneId}"
          else 
            "https://github.com/#{repositoryName}/"
        )

        # Add the daily individual time logs to the collection
        for userId in Object.keys(userProjectMilestones)
          dailyEntries = userProjectMilestones[userId]
          @get("rows").add(
            isHeader : false
            name : @usersCollection.getNameById(userId)
            sum : Utils.sum(dailyEntries)
            dailyTimeEntries : dailyEntries
            githubUrl : "https://github.com/#{@usersCollection.getGithubNameById(userId)}"
          )

module.exports = MilestoneViewModel

