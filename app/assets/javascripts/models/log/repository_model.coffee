### define
underscore : _
backbone : backbone
###

class RepositoryModel extends Backbone.Model

  url : ->
    "/api/repos/#{@get("id")}"
