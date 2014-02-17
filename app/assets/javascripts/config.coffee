unless require?
  requirejs = (config) -> window.require = config
else
  requirejs = require


requirejs

  baseUrl : "/assets/javascripts"

  paths :
    "jquery"              : "../bower_components/jquery/dist/jquery.min"
    "moment"              : "../bower_components/momentjs/min/moment.min"
    "underscore"          : "../bower_components/lodash/dist/lodash.min"
    "backbone"            : "../bower_components/backbone/backbone"
    "backbone.marionette" : "../bower_components/backbone.marionette/lib/backbone.marionette"
    "bootstrap"           : "../bower_components/bootstrap/dist/js/bootstrap.min"
    "backgrid"            : "backgrid"
    "datepicker"          : "bootstrap-datepicker"

  shim :
    "moment" :
      exports : "moment"
    "bootstrap" : ["jquery"]
    "backbone" :
      deps : ["jquery", "underscore"]
      exports : "Backbone"
    "backbone.marionette" :
      deps : ["backbone"]
      exports : "marionette"
    "datepicker" :
      deps : ["jquery"]
      exports : "datepicker"
    "backgrid" :
      deps: ["jquery", "backbone", "underscore"]
      exports: "Backgrid"
