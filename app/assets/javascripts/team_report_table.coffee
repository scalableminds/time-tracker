### define
jquery : $
underscore : _
backbone : Backbone
month_picker : MonthPicker
utils : Utils
###

class TeamReportTable extends Backbone.View

  className : "report-table"

  template : _.template("""
    <div class="row">
      <h2 class="col-lg-8"><%= userName %></h2>
      <div class="col-lg-4 picker"></div>
    </div>
    <div>
      <table id="timetable" class="table table-hover table-bordered table-striped">
        <thead>
          <tr>
            <% _.first(table).forEach(function (cell) { %>
              <th><%= cell.value %></th>
            <% }) %>
          </tr>
        </thead>
        <tbody>
          <% table.slice(1, -1).forEach(function (row) { %>
            <tr>
              <% row.forEach(function (cell) { %>
                <td<% if (cell.colspan) { %> colspan="<%= cell.colspan %>" <% } %><% if (cell.className) { %> class="<%= cell.className %>" <% } %>><%= cell.value %></td>
              <% }) %>
            </tr>
          <% }) %>
        </tbody>
        <tfoot>
          <tr>
            <% _.last(table).forEach(function (cell) { %>
              <th><%= cell.value %></th>
            <% }) %>
          </tr>
        </tfoot>
      </table>
    </div>
    <div class="popup">
      <h2>Iframe with new issue/ edit issue</h2>
      <!-- <iframe src="/404"></iframe> -->
    </div>
  """)


  events : 

    "click .edit-time" : "editTime"
    "click .popup" : -> @popup.hide()


  initialize : ->

    @currentDate = moment()
    console.log "@currentDate: ", @currentDate
    

    @monthPicker = new MonthPicker()


  editTime : (event) ->

    event.stopPropagation()

    $el = $(event.target)
    width = $el.width()
    value = $el.text()
    issueNumber = $el.data("issueNumber")

    @popup.toggle()


  render : ->
    @monthPicker.model = @currentDate
    
    @$el.append(@template(
      userName : "Team Overview"
      table : @prepareTable()
    ))

    @monthPicker.render()
    @$el.find(".picker").append(@monthPicker.el)

    @popup = @$el.find(".popup")


  prepareTable : ->

    table = []
    Cell = (value, colspan = 0, className = "") -> { value, colspan, className }

    # thead
    daysRange = _.range(1, @currentDate.endOf("month").date())

    table.push([Cell("User"), Cell("Project"), Cell("&sum;")].concat(
      _.map(daysRange, (a) -> Cell(Utils.zeroPad(a)))
    ))

    #tbody
    for user in @model

      timeEntries = user.times
      table.push([Cell(user.name, 3 + daysRange.length)])

      projectGroups = _.groupBy(timeEntries, (a) -> a.issue.project)

      for project, issues of projectGroups
        projectDaysGroups = _.groupBy(issues, (a) -> moment(a.date).date())

        table.push([
          Cell(""),
          Cell(project),
          Cell(Utils.sum(_.flatten(_.map(projectDaysGroups, (a) -> _.map(a, (b) -> b.duration)))))
        ].concat(
            _.map(daysRange, (day) -> Cell(Utils.sum(_.map(projectDaysGroups[day] ? [], (a) -> a.duration)) || "", 0, "edit-time"))
          )
        )

      #tfoot
      allEntries = _.flatten(_.map(this.model, (a) -> a.times))
      allDaysGroups = _.groupBy(allEntries, (a) -> moment(a.date).date())

      table.push([
        Cell(""), Cell(""), Cell(Utils.sum(_.map(allEntries, "duration")))
      ].concat(_.map(daysRange, (day) -> Cell(Utils.sum(_.map(allDaysGroups[day] ? [], (a) -> a.duration)) || ""))))

    table

