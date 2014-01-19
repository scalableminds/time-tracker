### define
jquery: $
backbone: Backbone
time_entry : TimeEntryCode
controller/user_report_controller : UserReportController
controller/project_report_controller : ProjectReportController
controller/team_report_controller : TeamReportController
views/admin/admin_panel : AdminPanel
###

class Router extends Backbone.Router

  routes:
    ""       : "user"
    "home"   : "user"
    "project": "project"
    "team"   : "team"
    "create" : "timeEntry"
    "admin"  : "admin"
    "repos/:owner/:repo/issues/:issueId/create" : "timeEntry"


  constructor: ->

    super({pushState: true})


  user: ->

    @changeView(new UserReportController())


  project: ->

    @changeView(new ProjectReportController())


  team: ->

    @changeView(new TeamReportController())


  timeEntry: ->

    TimeEntryCode()


  admin : ->

    @changeView(new AdminPanel())


  changeView: (view) ->

    view.render()
    $("#main-container .container").html(view.el)