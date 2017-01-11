Utils = require("utils")
Backbone = require("backbone")

class UserSettingsModel extends Backbone.Model

  defaults :
    "defaultRepository" : null
    "closeAfterGithub" : true

  url : "/api/user/settings"

module.exports = UserSettingsModel