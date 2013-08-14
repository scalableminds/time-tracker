define ["jquery"], ($) ->

  $ ->

    routes =  
      "^/home": ->
        require ["user_time_report"], (UserTimeReport) ->
          new UserTimeReport() 
      "^/team": ->
        require ["team_time_report"], (TeamTimeReport) ->
          new TeamTimeReport()
      "^/repos/[a-zA-Z]*/[a-zA-Z]*/issues/[0-9]*/create": ->
          require ["time_entry"], ->



    url = window.location.pathname

    for route, script of routes
      if RegExp(route).test(url)
        script()
        break;