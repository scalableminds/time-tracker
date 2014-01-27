### define
backbone.marionette : Marionette
underscore: _
moment: moment
utils: Utils
models/team_report_model: TeamReportModel
views/team_report_item: TeamReportItem
###

class TeamReport extends Backbone.Marionette.CompositeView

  modelEvents :
    "change" : "synced"

  title : "Team Report"
  template : _.template("""
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
          result[key] = _.range(0, @model.get("endOfMonth")).map(
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
      sumDaily = _.range(0, @model.get("endOfMonth")).map((i) -> return Utils.sum(_.values(timeEntries), i))
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
