Marionette = require("marionette")
_ = require("underscore")

class AvailableRepositoriesItemView extends Marionette.ItemView

  tagName: "option"
  template: _.template("""
    <%= name %>
  """)

  attributes : ->

    value : @model.get("name")
    id : @model.get("id")

module.exports = AvailableRepositoriesItemView