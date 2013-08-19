### define
jquery : $
underscore : _
backbone : Backbone
./month_picker : MonthPicker
./utils : Utils
###

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
            <% _.first(table).cells.forEach(function (cell) { %>
              <th><%= cell.value %></th>
            <% }) %>
          </tr>
        </thead>
        <tbody>
          <% table.slice(1, -1).forEach(function (row) { %>
            <tr class="<%= row.className %>" >
              <% row.cells.forEach(function (cell) { %>
                <td<% if (cell.colspan) { %> colspan="<%= cell.colspan %>" <% } %><% if (cell.className) { %> class="<%= cell.className %>" <% } %>><%= cell.value %></td>
              <% }) %>
            </tr>
          <% }) %>
        </tbody>
        <tfoot>
          <tr>
            <% _.last(table).cells.forEach(function (cell) { %>
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

    @groupByIterator = null
    @currentDate = moment()
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
      userName : @model.name or @model.email
      table : @prepareTable()
    ))

    @monthPicker.render()
    @$el.find(".picker").append(@monthPicker.el)

    @popup = @$el.find(".popup")


  prepareTable : ->

    table = []

    Row = (cells, className = "") -> {cells, className}
    Cell = (value, colspan = 0, className = "") -> { value, colspan, className }

    # thead
    daysRange = _.range(1, @currentDate.endOf("month").date() + 1)

    table.push(
      Row(
        [
          Cell("Issue")
          # , Cell("Summary")
          , Cell("&sum;")
        ].concat(_.map(daysRange, (a) -> Cell(Utils.zeroPad(a))))
      )
    )



    #tbody
    for element, elementEntries of @model.data
      
      elementDaysGroups = _.groupBy(elementEntries, (a) -> moment(a.date).date())

      table.push(
        Row(
          [
            Cell(element, 2)
            # , Cell(Utils.sum(_.map(elementEntries, "duration")))
          ].concat(
            _.map(daysRange, (day) -> Cell(Utils.minutesToHours(Utils.sum(_.map(elementDaysGroups[day] ? [], (a) -> a.duration))) || ""))
          ),
          "info"
        )
      )

      _.forOwn(_.groupBy(elementEntries, @groupByIterator),
        (entries) =>

          entriesDaysGroups = _.groupBy(entries, (a) -> moment(a.date).date())
          
          leftCells = [
            Cell(@groupByIteratorToString entries[0])
            # Cell(entries[0].title)       # summary
            Cell(Utils.minutesToHours(Utils.sum(_.map(entries, "duration"))))
          ]

          rightCells = _.map(
            daysRange, (day) =>
              value = Utils.minutesToHours(Utils.sum(
                _.map(entriesDaysGroups[day] ? [], (a) => a.duration)
              )) || ""
              
              return Cell(value, 0, @cellClass)
          )
          aRow = Row(leftCells.concat rightCells)
          table.push aRow
      )

    #tfoot
    allEntries = _.flatten(_.values(@model.data))
    allDaysGroups = _.groupBy(allEntries, (a) -> moment(a.date).date())


    rightCells = _.map(
      daysRange, (day) ->
        Cell(
          Utils.minutesToHours(Utils.sum(_.map(allDaysGroups[day] ? [], (a) -> a.duration))) || ""
        )
    )

    table.push Row(
      [ Cell("&sum;")
        # , Cell("")
        , Cell(Utils.minutesToHours(Utils.sum(_.map(allEntries, "duration"))))
      ].concat rightCells
    )

    table
