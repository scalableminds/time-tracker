### define
jquery : $
underscore : _
backbone : Backbone
moment : moment
###


class RowView extends Backbone.View
  
  events:

    "click .age": -> console.log(@model.get("name"))


  constructor: (@model) ->
    

  render: ->


    rowTemplate= _.template("<tr>"+
     "<td class='name'><%= name %></td>"+
     "<td class='age'><%= age %></td>"+
     "</tr>")


    html = rowTemplate(@model.toJSON())
    
    @setElement( $(html) )
    
    return @

