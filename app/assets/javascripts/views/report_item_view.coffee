###  define
backbone.marionette : Marionette
underscore: _
Utils: Utils
###

class ReportItemView extends Backbone.Marionette.ItemView

  tagName : "tr"

  template : _.template("""
    <td><%= name %></td>
    <td><%= Utils.minutesToHours(sum) %></td>
    <% _.each(dailyTimeEntries, function(day){ %>
      <td><%= Utils.minutesToHours(day) %></td>
    <% }) %>
  """)

  templateHelpers :
    Utils : Utils

  className : ->

    if @model.get("isHeader") then "project-row" else ""

