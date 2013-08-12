require [], ->

  routes =  
    "/": require ["home"], ->
    "/home": require ["home"], ->


  URL = window.location.pathname

  if routes.hasOwnProperty(URL)
    routes[URL]()