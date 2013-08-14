unless require?
  requirejs = (config) -> window.require = config
else
  requirejs = require


requirejs

  baseUrl : "/assets/javascripts"

  paths :
    "jquery" : "bower_components/jquery/jquery.min"
    "moment" : "bower_components/momentjs/min/moment.min"
    "bootstrap" : "bootstrap.min"

  shim :
    "moment" :
      exports : "moment"
    "bootstrap" : ["jquery"]