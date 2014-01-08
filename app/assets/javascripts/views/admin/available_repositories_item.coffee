### define
underscore : _
backbone.marionette : Marionette
###

class AvailableRepositoriesItem extends Backbone.Marionette.ItemView

  tagName: "option"
  template: _.template("""
    <%= repository %>
  """)

  initialize: ->

    @attributes =
      value: this.model.repository