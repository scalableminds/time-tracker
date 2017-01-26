_ = require("underscore")
Utils = require("utils")
Backbone = require("backbone")
moment = require("moment")
IssueCollection = require("./issue_collection")

class TeamTimeCollection extends Backbone.Collection

  url : ->

    dateUrl = Utils.dateToUrl(@date)
    return "/api/times/#{dateUrl}"


  fetch : (options = {}) =>
    if not this.withMilestones
      return super(options)
    return super(options)
      .then(
        () =>
          projectMap = @getAllProjectsWithIssueIds()
          issueCollections = Object.keys(projectMap)
            .map((projectName) -> new IssueCollection({ project: projectName }))
          return $.when(issueCollections.map((c) -> c.fetch())...)
            .then(() =>
              issueCollections.forEach((collection) => 
                @forEach((entry) ->
                  if entry.get("issueReference").project == collection.project
                    entry.set("milestone", 
                      collection.getIssueById(entry.get("issueReference").number)?.get("milestone"))
                )
              )
            )
      )


  getAllProjects : ->
    return _.unique(@map((entry) -> entry.get("issueReference").project))

  getAllProjectsWithIssueIds : ->
    return _.transform(
      @getAllProjects()
      (result, project) =>
        result[project] = _.unique(@models
          .filter((entry) -> entry.get("issueReference").project == project)
          .map((entry) -> entry.get("issueReference").number))
      {}
    )


  getMonthlyTotalHours : ->

    return @reduce(
      (sumTotal, entry) ->
        return sumTotal + entry.get("duration")
    , 0)


  getDailyTotalHours : (data) ->

    return Utils.range(1, @date.daysInMonth()).map(
      (day) =>
        momentDay = moment(@date).add("days", day - 1)
        @reduce(
          (sumTotal, entry) ->
            if moment(entry.get("dateTime")).isSame(momentDay, "day")
              return sumTotal + entry.get("duration")
            else
              return sumTotal
        , 0)
    )

module.exports = TeamTimeCollection