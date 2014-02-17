###  define
backbone.marionette : Marionette
underscore: _
Utils: Utils
###

class TeamReportItem extends Backbone.Marionette.ItemView

  tagName : "tr"
  templateForUserHeader : _.template("""
    <td><%= userName %></td>
    <td><%= Utils.minutesToHours(sumTotal) %></td>
    <% _.each(sumDaily, function(day){ %>
      <td><%= Utils.minutesToHours(day) %></td>
    <% }) %>
  """)

  templateForTimeEntries : _.template("""
    <td><%= projectName %></td>
    <td><%= Utils.minutesToHours(sumCompleteProject) %></td>
    <% _.each(timeEntry, function(day){ %>
      <td><%= Utils.minutesToHours(day) %></td>
    <% }) %>
  """)

  templateHelpers :
    Utils : Utils

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
