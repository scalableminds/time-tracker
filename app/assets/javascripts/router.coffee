### define
jquery: $
backbone: Backbone
moment: moment
time_entry : TimeEntryCode
controller/user_report_controller : UserReportController
controller/project_report_controller : ProjectReportController
controller/team_report_controller : TeamReportController
views/admin/admin_panel : AdminPanelView
views/time_report : TimeReportView
views/team_report : TeamReportView
###

class Router extends Backbone.Router

  routes:
    ""        : "user"
    "home/"   : "user"
    "project/": "project"
    "team/"   : "team"
    "create/" : "timeEntry"
    "admin/"  : "admin"
    "team/:date" : "team"
    "repos/:owner/:repo/issues/:issueId/create" : "timeEntry"
    "*url"  : "redirectWithSlash"

  whitelist: [
    "/authenticate/github"
  ]



  constructor: ->

    super({pushState: true})


  user: ->

    @changeView(new UserReportController())


  project: ->

    @changeView(new ProjectReportController())


  team: (date) ->

    @changeView(new TimeReportView(TeamReportView, moment(date)))


  timeEntry: ->

    TimeEntryCode()


  admin : ->

    @changeView(new AdminPanelView())


  redirectWithSlash : (url) ->

    urlWithSlash = "#{url}/"
    if _.has(@routes, urlWithSlash)
      @navigate(urlWithSlash, true)
    else
      @user()


  changeView: (view) ->

    view.render()
    $("#main-container .container").html(view.el)


  handlePageLinks : ->

    # Globally capture clicks and route them through Backbone's navigate method.
    $(document).on "click", "a[href^='/']", (event) ->

      url = $(event.currentTarget).attr('href')

      # Check if url is whitelisted
      if whitelist.contains(url)
        return

      # Allow shift+click for new tabs, etc.
      if !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey
        event.preventDefault()

        # Instruct Backbone to trigger routing events
        app.router.navigate(url, { trigger: true })

        return false