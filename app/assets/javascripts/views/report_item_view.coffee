Marionette = require("marionette")
_ = require("underscore")
Utils = require("utils")

class ReportItemView extends Marionette.ItemView

  tagName : "tr"

  template : _.template("""
    <td title="<%= name %>" class="truncate">
      <% if(githubUrl){ %>
        <a href="<%= githubUrl %>" target="_blank"><%= name %></a>
      <% } else { %>
        <%= name %>
      <% }%>
    </td>
    <td><%= Utils.minutesToHours(sum) %></td>
    <% _.each(dailyTimeEntries, function(day){ %>
      <td><%= Utils.minutesToHours(day) || "" %></td>
    <% }) %>
  """)

  templateHelpers :
    Utils : Utils

  className : ->

    if @model.get("isHeader") then "project-row" else ""

module.exports = ReportItemView