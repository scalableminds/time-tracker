### define
underscore : _
backbone : Backbone
views/report_view  : ReportView
views/spinner_view  : SpinnerView
views/admin/admin_panel_view  : AdminPanelView
views/month_picker_view : MonthPickerView
views/log/log_time_local_view  : LogTimeLocalView
views/log/log_time_github_view  : LogTimeGithubView
views/settings/user_settings_view  : UserSettingsView
models/team/team_viewmodel : TeamViewModel
models/project/project_viewmodel : ProjectViewModel
models/user/user_viewmodel : UserViewModel
models/settings/user_settings_model : UserSettingsModel
models/log/log_time_model : LogTimeModel
###

class Router extends Backbone.Router

  routes :
    "log"                                       : "log"
    "home"                                      : "user"
    "home/:date"                                : "user"
    "project"                                   : "project"
    "project/:date"                             : "project"
    "admin"                                     : "admin"
    "team"                                      : "team"
    "team/:date"                                : "team"
    "repos/:repoId/issues/:issueId/create"      : "logFromGithub"
    "settings"                                  : "settings"

  whitelist : [
    "/authenticate/github"
    "/faq"
  ]

  initialize  : ->

    @handlePageLinks()
    @activeViews = null
    @$mainContainer = $("#main-container")


  user : (date) ->

    userModel = new UserViewModel(date : date)
    @showReport(userModel)
    @changeActiveNavbarItem("/")


  project : (date) ->

    projectModel = new ProjectViewModel(date : date)
    @showReport(projectModel)
    @changeActiveNavbarItem("/project")


  team : (date) ->

    teamModel = new TeamViewModel(date : date)
    @showReport(teamModel)
    @changeActiveNavbarItem("/team")


  log : ->

    logTimeModel = new LogTimeModel()
    @changeView(new LogTimeLocalView(model : logTimeModel))
    @changeActiveNavbarItem("/log")


  logFromGithub : (repositoryId, issueNumber) ->

    logTimeModel = new LogTimeModel({repositoryId, issueNumber})
    @changeView(new LogTimeGithubView(model : logTimeModel))
    @changeActiveNavbarItem("/log")


  admin : ->

    @changeView(new AdminPanelView())
    @changeActiveNavbarItem("/admin")


  settings : ->

    userSettingsModel = app.settings
    userSettingsView = new UserSettingsView(model : userSettingsModel)
    spinnerView = new SpinnerView(model : userSettingsModel)
    @changeView(spinnerView, userSettingsView)
    userSettingsModel.fetch()
    @changeActiveNavbarItem()


  faq  : ->

    @changeActiveNavbarItem("/faq")


  showReport : (model) ->

    spinnerView = new SpinnerView(model : model)
    monthPickerView = new MonthPickerView(model : model)
    reportView = new ReportView(model : model)

    @changeView(spinnerView, monthPickerView, reportView)


  changeView : (views...) ->

    $("#main-container").addClass("container wide")

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


  changeActiveNavbarItem : (url) ->

    $navbar = $("#main-nav")
    $navbar.find(".active").removeClass("active")
    if url
      $navbar.find("a[href=\"#{url}\"]").closest("li").addClass("active")

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


  execute : (callback, args) ->

    super(callback, args.map( (a) -> a or undefined ))
    return
