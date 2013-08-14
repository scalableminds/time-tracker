define ["jquery"], ($) ->

  $ ->

    routes =  
      "^/home": ->
        require ["user_time_report"], (UserTimeReport) ->
          new UserTimeReport()
      "^/repos/[a-z]*/[a-z]*/issues/[0-9]*/create": ->
          require ["time_entry"], ->

    url = window.location.pathname

    for route, script of routes
      if RegExp(route).test(url)
        script()
        break;