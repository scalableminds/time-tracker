Backbone = require("backbone")

class ActiveRepositoriesCollection extends Backbone.Collection

  url : "/api/repos"

module.exports = ActiveRepositoriesCollection