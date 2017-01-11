Marionette = require("marionette")
_ = require("underscore")

class SelectionItemView extends Marionette.ItemView

  tagName : "option"

  template : _.template("""
    <%= label %>
  """)

  initialize : (options) ->

    @getValue = options.valueFunc
    @getLabel = options.labelFunc ? options.valueFunc

  serializeData : ->

    return {
      label : @getLabel()
    }


  onRender : ->

    @$el.attr(
      id : @model.get("id")
      value : @getValue()
    )

module.exports = SelectionItemView