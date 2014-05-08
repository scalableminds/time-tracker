### define
underscore : _
backbone : Backbone
###

class ActiveRepositoriesCollection extends Backbone.Collection

  url : "/repos"

  defaults :
    admin : "someone"
