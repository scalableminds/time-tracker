define ["jquery", "user_time_report", "team_time_report", "time_entry"], ($, UserTimeReport, TeamTimeReport, TimeEntryCode) ->

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
        new UserTimeReport() 
      "/team" : ->
        new TeamTimeReport()
      "/repos/:owner/:repo/issues/:issueId/create" : ->
        TimeEntryCode()
