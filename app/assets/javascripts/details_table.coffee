### define
jquery : $
underscore : _
backbone : Backbone
./utils : Utils
###

class DetailsTable extends Backbone.View

  className : "modal-dialog"

  template : _.template("""
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h4 class="modal-title"><%= title %></h4>
      </div>
      <div class="modal-body" style="overflow-y: auto; max-height: 800px">
        <div>
	  <table id="timetable" class="table table-hover table-bordered table-striped responsive">
            <thead>
              <tr>
                <% _.first(table).cells.forEach(function (cell) { %>
                  <th<% if (cell.className) { %> class="<%= cell.className %>" <% } %>><%= cell.value %></th>
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
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
        <!--<button type="button" class="btn btn-primary">Save changes</button>-->
      </div>
    </div>
  """)


  # events :

  initialize : ->


  render : ->

    @$el.append(@template(
      title : "Details"
      table : @prepareTable()
    ))


  prepareTable : ->

    table = []

    Row = (cells, className = "") -> { cells, className }
    Cell = (value, colspan = 0, className = "") -> { value, colspan, className }

    # thead

    table.push(
      Row(
        [
          Cell("Time"),
          Cell("Comment"),
          Cell("Duration")
        ]
      )
    )

    if @model

      #tbody
      for element in @model
        table.push(
          Row([
            Cell(moment(element.date).format("hh:mm") + " h"),
            Cell(element.comment or ""),
            Cell(Utils.minutesToHours(element.duration))
          ])
        )
    else
      table.push(Row(["", "", ""]))


    # don't display summarizing tfoot if there is only one log
    if table.length > 2

      sumOfDurations = Utils.minutesToHours(Utils.sum(_.map(@model, (a) -> a.duration))) || ""

      table.push(Row([Cell(""), Cell(""), Cell("&sum; " + sumOfDurations)]))


    table
