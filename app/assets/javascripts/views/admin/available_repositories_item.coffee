### define
underscore : _
backbone.marionette : Marionette
###

class AvailableRepositoriesItem extends Backbone.Marionette.ItemView

  tagName: "option"
  template: _.template("""
    <%= name %>
  """)

  attributes : ->

    value: @model.get("name")