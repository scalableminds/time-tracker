###  define
backbone.marionette : Marionette
underscore: _
utils: Utils
###

class TeamReportItem extends Backbone.Marionette.ItemView

  className: "project-row"
  tagName: "tr"
  template: _.template("""
    <% _.each(row, function(entry){ %>
      <td><%= entry %></td>
    <% }) %>
  """)