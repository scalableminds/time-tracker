### define
underscore : _
backbone : Backbone
views/admin/admin_panel  : AdminPanelView
views/report_view  : ReportView
views/month_picker_view : MonthPickerView
views/log/log_time_view  : LogTimeView
views/spinner_view  : SpinnerView
models/team/team_viewmodel : TeamViewModel
models/project/project_viewmodel : ProjectViewModel
###

class Router extends Backbone.Router

  routes :
    ""                                          : "user"
    "home"                                      : "user"
    "log"                                       : "log"
    "project"                                   : "project"
    "project/:date"                             : "project"
    "admin"                                     : "admin"
    "team"                                      : "team"
    "team/:date"                                : "team"
    "repos/:owner/:repo/issues/:issueId/create" : "timeEntry"

  whitelist : [
    "/authenticate/github"
  ]

  initialize  : ->

    @handlePageLinks()
    @activeViews = null
    @$mainContainer = $("#main-container .container")


  user : ->

    #@changeView(new UserReportController())


  project : (date) ->

    projectModel = new ProjectViewModel("date" : date)
    spinnerView = new SpinnerView(model : projectModel)
    monthPickerView = new MonthPickerView(model : projectModel)
    reportView = new ReportView(model : projectModel)

    @changeView(spinnerView, monthPickerView, reportView)


  team : (date) ->

    teamModel = new TeamViewModel("date" : date)
    spinnerView = new SpinnerView(model : teamModel)
    monthPickerView = new MonthPickerView(model : teamModel)
    reportView = new ReportView(model : teamModel)

    @changeView(spinnerView, monthPickerView, reportView)


  log : ->

    @changeView(new LogTimeView())


  admin  : ->

    @changeView(new AdminPanelView())


  changeView : (views...) ->

    if @activeViews == views
      return

    # Remove current views
    if @activeViews
      for view in @activeViews
        # prefer Marionette's close() function to Backbone's remove()
        if view.close
          view.close()
        else
          view.remove()
    else
      # we are probably coming from a URL that isn't a Backbone.View yet (or page reload)
      @$mainContainer.empty()

    # Add new views
    @activeViews = views

    for view in views
      @$mainContainer.append(view.render().el)

    return


  handlePageLinks  : ->

    # handle all links and manage page changes (rather the reloading the whole site)
    $(document).on("click", "a", (evt) =>

      url = $(evt.currentTarget).attr("href")
      if url == "#"
        return

      if _.contains(@whitelist, url)
        return

      urlWithoutSlash = url.slice(1)
      if @routes[urlWithoutSlash]
        evt.preventDefault()
        @navigate(url, trigger : true)

      return
    )
