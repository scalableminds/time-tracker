### define
jquery : $
bootstrap : bootstrap
time_entry : TimeEntryCode
controller/user_report_controller : UserReportController
controller/project_report_controller : ProjectReportController
controller/team_report_controller : TeamReportController
datepicker : datepicker
###

$ ->

  route = (routes) ->

    optionalParam = /\((.*?)\)/g
    namedParam    = /(\(\?)?:\w+/g
    splatParam    = /\*\w+/g
    escapeRegExp  = /[\-{}\[\]+?.,\\\^$|#\s]/g

    routeToRegExp = (route) ->
      route = route
        .replace(escapeRegExp, '\\$&')
        .replace(optionalParam, '(?:$1)?')
        .replace(namedParam, (match, optional) ->
          if optional then match else '([^\/]+)'
        )
        .replace(splatParam, '(.*?)')
      new RegExp('^' + route + '$')

    url = window.location.pathname
    for route, script of routes
      if routeToRegExp(route).test(url)
        script()
        return

  route

    "/home" : ->

      controller = new UserReportController()


    "/project" : ->
      controller = new ProjectReportController()

    "/team" : ->
      
      controller = new TeamReportController()


    "/repos/:owner/:repo/issues/:issueId/create" : ->

      TimeEntryCode()

    "/create" : ->

      TimeEntryCode()

      $issueNumber = $("#issueNumber")

      actionUpdater = ->
        selectedRepo = $("select option:selected").val()
        actionURL = "/repos/" + selectedRepo + "/issues/" + $issueNumber.val()

        $('form').get(0).setAttribute('action', actionURL)

      $("select[name=repository]").change(actionUpdater)
      $issueNumber.change(actionUpdater)


      actionUpdater()


    "/user/settings" : ->
      
      $("#generateKey").click ->
        $.ajax({url : $(this).data("url"), method : 'post'}).done ->
          location.reload()


    "/admin/repositories" : ->

      $("#deleteRepository").click ->
        $.ajax({url : $(this).data("url"), method : 'delete'}).done ->
          location.reload()