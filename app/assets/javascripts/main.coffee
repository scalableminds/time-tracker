### define
jquery : $
backbone.marionette : Marionette
app : App
router : Router
###

$ ->

  app = new App()

  app.addInitializer ->

    app.router = new Router()

    $(document).on("backbutton", (event) -> app.trigger("backbutton", event))
    Backbone.history.start({pushState: true})


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


  #   "/admin" : ->

  #     controller = new AdminPanel(el: "#main-container .container")
  #     controller.render()

  #   "/admin/repositories" : ->

  #     $("#deleteRepository").click ->
  #       $.ajax({url : $(this).data("url"), method : 'delete'}).done ->
  #         location.reload()
