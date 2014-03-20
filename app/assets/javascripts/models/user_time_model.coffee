### define
backbone : backbone
moment : moment
Utils : Utils
###

class UserTimeModel extends Backbone.Model

  defaults :
    currentDate : moment().subtract("month", 2)


  urlRoot : ->

    dateUrl = Utils.dateToUrl(@get("currentDate"))
    return "/user/times/#{dateUrl}"


  initialize : ->

    @listenTo(@, "sync", @projectsToCollections)


  # after syncing to the server wrap all the issues/timings as collections
  projectsToCollections : ->

    projects = @get("projects")

    for name, issues of projects
      projects[name] = new Backbone.Collection(issues)

    @set("projects", projects)


  getIssuesByProject : (projectName) ->

    project = @get("projects")[projectName]

    if project
      return project

    else
      throw new Error("There is no project called '#{projectName}'")