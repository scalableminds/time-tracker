// Generated by CoffeeScript 1.6.2
require([], function() {
  var URL, routes;

  routes = {
    "/": require(["home"], function() {}),
    "/home": require(["home"], function() {})
  };
  URL = window.location.pathname;
  if (routes.hasOwnProperty(URL)) {
    return routes[URL]();
  }
});
