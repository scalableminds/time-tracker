require.config

  baseUrl : "/assets/javascripts"

  paths :
    "jquery" : "bower_components/jquery/jquery.min"
    "moment" : "bower_components/momentjs/min/moment.min"

  shim :
    "moment" :
      exports : "moment"

require [
  "routing"
], ->
