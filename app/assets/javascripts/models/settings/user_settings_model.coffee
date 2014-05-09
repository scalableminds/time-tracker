### define
backbone : Backbone
utils : Utils
###

class UserSettingsModel extends Backbone.Model

  defaults :
    "defaultRepository" : null
    "closeAfterGithub" : true

  url : "/api/user/settings"

