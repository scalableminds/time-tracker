unless require?
  requirejs = (config) -> window.require = config
else
  requirejs = require


requirejs

  baseUrl : "/assets/javascripts"

  paths :
    "jquery"              : "../bower_components/jquery/dist/jquery"
    "moment"              : "../bower_components/momentjs/moment"
    "underscore"          : "../bower_components/lodash/dist/lodash"
    "backbone"            : "../bower_components/backbone/backbone"
    "backbone.marionette" : "../bower_components/backbone.marionette/lib/backbone.marionette"
    "bootstrap"           : "../bower_components/bootstrap/dist/js/bootstrap"
    "datepicker"          : "bootstrap-datepicker"

  shim :
    "moment" :
      exports : "moment"
    "bootstrap" : ["jquery"]
    "backbone.marionette" :
      deps : ["backbone"]
      exports : "Marionette"
    "datepicker" :
      deps : ["jquery"]
      exports : "datepicker"
