### define
underscore : _
backbone.marionette : Marionette
###

class SelectionItemView extends Backbone.Marionette.ItemView

  tagName : "option"

  template : _.template("""
    <%= label %>
  """)

  initialize : (options) ->

    @getValue = options.valueFunc
    @getLabel = options.labelFunc ? options.valueFunc
    @listenTo(this, "render", @afterRender)


  serializeData : ->

    return {
      label : @getLabel()
    }


  afterRender : ->

    @$el.attr(
      id : @model.get("id")
      value : @getValue()
    )