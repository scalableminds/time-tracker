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

  #   "/create" : ->

  #     TimeEntryCode()

  #     $issueNumber = $("#issueNumber")

  #     actionUpdater = ->
  #       selectedRepo = $("select option:selected").val()
  #       actionURL = "/repos/" + selectedRepo + "/issues/" + $issueNumber.val()

  #       $('form').get(0).setAttribute('action', actionURL)

  #     $("select[name=repository]").change(actionUpdater)
  #     $issueNumber.change(actionUpdater)


  #     actionUpdater()


  #   "/user/settings" : ->

  #     $("#generateKey").click ->
  #       $.ajax({url : $(this).data("url"), method : 'post'}).done ->
  #         location.reload()


  #   "/admin/repositories" : ->

  #     $("#deleteRepository").click ->
  #       $.ajax({url : $(this).data("url"), method : 'delete'}).done ->
  #         location.reload()
