SelectionItemView = require("./selection_item_view")
Marionette = require("marionette")

class SelectionView extends Marionette.CollectionView

  tagName : "select"
  className: "form-control"

  itemView : SelectionItemView

  initialize : (options) ->

    @name = options.name
    @collection.fetch().done(@render.bind(this))


  onRender : ->

    @$el.attr("name", @name)
    return


  getValue : ->

    return @el.value


  setValue : (value) ->

    @el.value = value
    return

module.exports = SelectionView