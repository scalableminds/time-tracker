define ["jquery"], ($) ->

  $ ->

    routes =  
      "/": ->
        require ["user_time_report"], (UserTimeReport) ->
          new UserTimeReport()
      "/home": ->
        require ["user_time_report"], (UserTimeReport) ->
          new UserTimeReport()


    url = window.location.pathname

    if routes.hasOwnProperty(url)
      routes[url]()