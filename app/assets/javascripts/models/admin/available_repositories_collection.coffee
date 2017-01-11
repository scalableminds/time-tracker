Backbone = require("backbone")

class AvailableRepositoriesCollection extends Backbone.Collection

  url : "/api/user/repos"

module.exports = AvailableRepositoriesCollection