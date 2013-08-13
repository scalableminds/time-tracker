define ["jquery"], ($) ->

  $ ->

    routes =  
      "/home": ->
        require ["user_time_report"], (UserTimeReport) ->
          new UserTimeReport()

    url = window.location.pathname

    if routes.hasOwnProperty(url)
      routes[url]()