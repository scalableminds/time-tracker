###  define
backbone.marionette : Marionette
underscore: _
###

class TeamReportItem extends Backbone.Marionette.ItemView

  tagName : "tr"
  templateForUserHeader : _.template("""
    <td><%= userName %></td>
    <td><%= sumTotal %></td>
    <% _.each(sumDaily, function(day){ %>
      <td><%= day %></td>
    <% }) %>
  """)

  templateForTimeEntries : _.template("""
    <td><%= projectName %></td>
    <td><%= sumCompleteProject %></td>
    <% _.each(timeEntry, function(day){ %>
      <td><%= day %></td>
    <% }) %>
  """)

  attributes: ->

    className = if @model.get("isUserHeader") then "project-row" else ""
    return {
      class: className
    }

  initialize : ->

    # This is a bit hacky. Haven't found a better just yet.
    if @model.get("isUserHeader")
      @template = @templateForUserHeader
    else
      @template = @templateForTimeEntries

