### define
jquery : $
underscore : _
backbone : Backbone
moment : moment
row_view : RowView
###


class TableView extends Backbone.View

  tagName: 'table'


  constructor: (@collection) ->



  initialize : -> 

    _.bindAll(this, 'render', 'renderOne')

  
  render: ->

    @collection.each( (model) =>

      row = new RowView(model)
      
      @$el.append(row.render().$el)
      # @setElement( row.render().$el )

      return @

    )

    return @
  

  


  

