### define
jquery : $
underscore : _
backbone : Backbone
report : Report
./month_picker : MonthPicker
./utils : Utils
###

# data = {
#   "user" : "tmbo",
#   "projects": {
#     "brainflight": 
#       [
#         { 
#             "issueNumber": 0,
#             "duration": 10
#             "title": "BF-101 Build time tracker"
#             "date": "2013-08-01T00:08:59.181Z"
#         },
#         {
#             "issueNumber": 2,
#             "duration": 60
#             "title": "BF-12 Work some more!"
#             "date": "2013-08-12T00:08:59.181Z"
#         },
#         {
#           "issueNumber": 2,
#           "duration": 60
#           "title": "BF-12 Work some more!"
#           "date": "2013-08-12T00:18:59.181Z"
#         }
#       ]
#     ,"oxalis": 
#       [
#         { 
#             "issueNumber": 4,
#             "duration": 10
#             "title": "OX-1 satisfy Moritz"
#             "date": "2013-08-30T00:08:59.181Z"
#         },
#         {
#             "issueNumber": 12,
#             "duration": 60
#             "title": "OX-1000 sell Oxalis"
#             "date": "2013-08-10T00:08:59.181Z"
#         }
#       ]
#     }
# }

class ReportTable extends Backbone.View

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

    console.log "report-table is initializing"
    
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
    
    console.log "rendering is triggered"
  
    @$el.append(@template(
      userName : @model.name or @model.email
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

    table.push([Cell("Issue"), Cell("Summary"), Cell("&sum;")].concat(
      _.map(daysRange, (a) -> Cell(Utils.zeroPad(a)))
    ))

    #tbody
    for project, projectEntries of @model.projects
      
      projectDaysGroups = _.groupBy(projectEntries, (a) -> moment(a.date).date())

      table.push(
        [Cell(project, 2), Cell(Utils.sum(_.map(projectEntries, "duration")))].concat(
          _.map(daysRange, (day) -> Cell(Utils.sum(_.map(projectDaysGroups[day] ? [], (a) -> a.duration)) || ""))
        )
      )

      _.forOwn(_.groupBy(projectEntries, "title"),
        (entries) ->

          entriesDaysGroups = _.groupBy(entries, (a) -> moment(a.date).date())

          table.push([
            Cell(entries[0].issueNumber) # issue
            Cell(entries[0].title)       # summary
            Cell(Utils.sum(_.map(entries, "duration")))
          ].concat(_.map(daysRange, (day) -> Cell(Utils.sum(_.map(entriesDaysGroups[day] ? [], (a) -> a.duration)) || "", 0, "edit-time"))))
      )

    #tfoot
    allEntries = _.flatten(_.values(@model.projects))
    allDaysGroups = _.groupBy(allEntries, (a) -> moment(a.date).date())

    table.push([
      Cell(""), Cell(""), Cell(Utils.sum(_.map(allEntries, "duration")))
    ].concat(_.map(daysRange, (day) -> Cell(Utils.sum(_.map(allDaysGroups[day] ? [], (a) -> a.duration)) || ""))))

    table


