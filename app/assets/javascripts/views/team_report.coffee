### define
backbone.marionette : Marionette
underscore: _
moment: moment
models/team_report_collection: TeamReportCollection
views/team_report_item: TeamReportItem
###

class TeamReport extends Backbone.Marionette.CompositeView

  title: "Team Report"
  template: _.template("""
    <table class="table table-hover table-bordered table-striped responsive">
      <thead>
        <tr>
          <th>Issue</th>
          <th>&sum;</th>
          <% _.each(_.range(0, endOfMonth), function(index){ %>
            <th><%= index %></th>
          <% }) %>
        </tr>
      </thead>
      <tbody></tbody>
    </table>
  """)


  itemView: TeamReportItem
  itemViewContainer: "tbody"

  initialize : (date) ->

    @model = new TeamReportCollection(date)
    @collection = @model.get("rows")
    @listenTo(app, "datePicker:dateChanged", @update)


  update : (event) ->

    #TODO
    date = null
    @model.updateDate(date)
    return