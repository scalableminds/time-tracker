UserSettingsModel = require("models/settings/user_settings_model")
Router = require("./router")
Backbone = require("backbone")
$ = require("jquery")
app = require("app")
require("./vendor/alert")
require("./vendor/bootstrap-datepicker")

$ ->

  app.addInitializer ->

    app.settings = new UserSettingsModel()
    app.settings.fetch()
    return

  app.addInitializer ->

    app.router = new Router()

    $(document).on("backbutton", (event) -> app.trigger("backbutton", event))
    Backbone.history.start(pushState: true)
    return


  app.start()
