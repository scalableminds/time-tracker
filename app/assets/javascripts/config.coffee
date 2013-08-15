unless require?
  requirejs = (config) -> window.require = config
else
  requirejs = require


requirejs

  baseUrl : "/assets/javascripts"

  paths :
    "jquery" : "bower_components/jquery/jquery.min"
    "moment" : "bower_components/momentjs/min/moment.min"
    "underscore" : "bower_components/lodash/dist/lodash.min"
    "backbone" : "bower_components/backbone/backbone-min"
    "bootstrap" : "bootstrap.min"

  shim :
    "moment" :
      exports : "moment"
    "bootstrap" : ["jquery"]
    "backbone" : 
    	deps : ["jquery", "underscore"]
    	exports : "Backbone"