Marionette = require("marionette")
_ = require("underscore")
Utils = require("utils") 
ReportItemView = require("./report_item_view")
app = require("app")


class ReportView extends Marionette.CompositeView

  className : "time-report"
  template : _.template("""
    <h3 class="view-title"><%= viewTitle %></h3>
    <table class="table table-hover table-bordered table-striped responsive">
      <thead>
        <tr>
          <th>Issue</th>
          <th>&sum;</th>
          <% _.each(Utils.range(1, date.daysInMonth()), function(index){ %>
            <th><%= index %></th>
          <% }) %>
        </tr>
      </thead>
      <tbody></tbody>
      <tfoot>
        <tr>
          <td>&sum;</td>
          <td><%= Utils.minutesToHours(monthlyTotalHours) %></td>
          <% _.each(dailyTotalHours, function(day){ %>
            <td><%= Utils.minutesToHours(day) || "" %></td>
          <% }) %>
        </tr>
      </tfoot>
    </table>
  """)

  templateHelpers :
    Utils : Utils

  itemView : ReportItemView
  itemViewContainer : "tbody"

  initialize : ->

    @collection = @model.get("rows")

    @listenTo(app.vent, "MonthPickerView:changed", @update)
    @listenTo(@model, "sync", @render)


    @model.fetch(
      reset : true
    )

module.exports = ReportView

