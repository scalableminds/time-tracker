### define
backbone.marionette : Marionette
underscore: _
utils: Utils
models/team_report_model: TeamReportModel
views/team_report_item: TeamReportItem
###

class TeamReport extends Backbone.Marionette.CompositeView

  modelEvents :
    "sync" : "synced"

  title : "Team Report"
  template : _.template("""
    <table class="table table-hover table-bordered table-striped responsive">
      <thead>
        <tr>
          <th>Issue</th>
          <th>&sum;</th>
          <% _.each(_.range(1, endOfMonth), function(index){ %>
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
            <td><%= Utils.minutesToHours(day) %></td>
          <% }) %>
        </tr>
      </tfoot>
    </table>
  """)

  templateHelpers :
    Utils : Utils

  itemView : TeamReportItem
  itemViewContainer : "tbody"

  initialize : (date) ->

    @model = new TeamReportModel(date)
    @model.fetch()
    @collection = @model.get("rows")


  synced : ->

    # Call this after the model is initalized and format the data to fit this view
    users = @model.get("api")

    # Iterate of every user...
    _.each(users, (user) =>

      # and group his issue by his repositories (aka projects)
      timeEntries = _.groupBy(user.times, (timeEntry) -> timeEntry.issue.project)

      # Finally add the days of the month to every project...
      timeEntries = _.transform(timeEntries,
        (result, project, key) =>
          result[key] = _.range(1, @model.get("endOfMonth")).map(
            (day) -> return Utils.sum(
              project.filter(
                (project) -> return moment(project.timestamp).date() == day
              ).map(
                (projectFilterdByDay) -> return projectFilterdByDay.duration
              )
            )
          )
        )

      # Sum up the total amount of hours per day for every user
      sumDaily = _.range(1, @model.get("endOfMonth")).map((i) -> return Utils.sum(_.values(timeEntries), i - 1)) #-1 because days start with 1 and arrays with 0
      sumTotal = Utils.sum(sumDaily)

      #Add that shit to the collection as a table 'header' for every user
      @model.get("rows").add(
        isUserHeader : true
        userName : user.name
        sumTotal : sumTotal
        sumDaily : sumDaily
      )

      # Add the daily individual time logs to the collection
      _.each(timeEntries, (timeEntry, projectName) =>
        sumCompleteProject = Utils.sum(timeEntry)
        @model.get("rows").add(
          isUserHeader : false
          projectName : projectName
          sumCompleteProject : sumCompleteProject
          timeEntry : timeEntry
        )
      )
    )

    # Make sure we render everything again
    # TODO does this cause 2x renders? one with this call and one because the collection changed?
    @render()
