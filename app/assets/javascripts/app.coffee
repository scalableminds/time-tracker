### define
jquery : $
backbone.marionette : Marionette
###

class App extends Backbone.Marionette.Application

  constructor:->

    super()

    window.app = @
    @handlePageLinks()


  handlePageLinks : ->

  # Globally capture clicks and route them through Backbone's navigate method.
  $(document).on "click", "a[href^='/']", (event) ->

    url = $(event.currentTarget).attr('href')

    # Allow shift+click for new tabs, etc.
    if !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey
      event.preventDefault()

      # Instruct Backbone to trigger routing events
      app.router.navigate(url, { trigger: true })

      return false