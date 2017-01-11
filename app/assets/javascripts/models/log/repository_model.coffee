Backbone = require("backbone")

class RepositoryModel extends Backbone.Model

  url : ->
    "/api/repos/#{@get("id")}"

module.exports = RepositoryModel