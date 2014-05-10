### define
underscore : _
backbone.marionette : Marionette
###

class AvailableRepositoriesItemView extends Backbone.Marionette.ItemView

  tagName: "option"
  template: _.template("""
    <%= name %>
  """)

  attributes : ->

    value : @model.get("name")
    id : @model.get("id")