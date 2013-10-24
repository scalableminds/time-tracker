### define
jquery : $
underscore : _
backbone : Backbone
details_table : DetailsTable
./month_picker : MonthPicker
###

class ReportTable extends Backbone.View

  className : "report-table"

  template : _.template("""
    <div class="row">
      <h2 class="col-lg-8"><%= title %></h2>
      <div class="col-lg-4 picker"></div>
    </div>
    <div>
      <table id="timetable" class="table table-hover table-bordered table-striped">
        <thead>
          <tr>
            <% _.first(table).cells.forEach(function (cell) { %>
              <th<% if (cell.className) { %> class="<%= cell.className %>" <% } %>><%= cell.value %></th>
            <% }) %>
          </tr>
        </thead>
        <tbody>
          <% table.slice(1, -1).forEach(function (row) { %>
            <tr class="<%= row.className %>" data-group-by-identifier="<%= row.groupByIdentifier %>" data-entity-identifier="<%= row.entityIdentifier %>">
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
    <div class="modal fade" id="modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="overflow: hidden"></div>

  """)


  events : 

    "click .edit-time" : "editTime"


  initialize : ->

    @groupByIterator = null
    @currentDate = moment()
    @monthPicker = new MonthPicker()


  editTime : (event) ->
    
    event.stopPropagation()
    
    $el = $(event.target)
    $parent = $el.parent()
    
    groupByIdentifier = $parent.data("group-by-identifier")
    entityIdentifier = $parent.data("entity-identifier")

    sectionEntries = @model.data[groupByIdentifier]
    groupedEntries = _.groupBy(sectionEntries, @groupByIterator)
    monthEntries = groupedEntries[entityIdentifier]
    entriesDaysGroups = _.groupBy(monthEntries, (a) -> moment(a.date).date())

    # Range of dayEntries begins with 1. The first-day-of-the-month-column has the index 2.
    day = $el[0].cellIndex - 1
    dayEntries = entriesDaysGroups[day]
  
    detailsTable = new DetailsTable()
    detailsTable.model = dayEntries
    detailsTable.render()

    $("#modal").html(detailsTable.el).modal("show")


  render : ->

    @monthPicker.model = @currentDate
  
    @$el.append(@template(
      title : @model.title
      table : @prepareTable()
    ))

    @monthPicker.render()
    @$el.find(".picker").append(@monthPicker.el)

    @popup = @$el.find(".popup")


  prepareTable : ->

    return @table
