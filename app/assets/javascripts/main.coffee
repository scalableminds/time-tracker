### define
jquery : $
backbone.marionette : Marionette
app : app
router : Router
bootstrap : bootstrap
models/settings/user_settings_model : UserSettingsModel
###

$ ->

  app.addInitializer ->

    app.settings = new UserSettingsModel()
    app.settings.fetch()
    return


  app.addInitializer ->

    $ ->
      $("#main-container").addClass("container wide")


  app.addInitializer ->

    app.router = new Router()

    $(document).on("backbutton", (event) -> app.trigger("backbutton", event))
    Backbone.history.start(pushState: true)
    return


  app.start()
