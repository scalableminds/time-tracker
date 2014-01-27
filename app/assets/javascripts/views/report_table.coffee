### define
jquery : $
underscore : _
backbone : Backbone
backgrid : Backgrid
./details_table : DetailsTable
./month_picker : MonthPicker
../utils : Utils
../backgrid_modifications : BackgridModifications
###

class ReportTable extends Backbone.View

  className : "report-table"

  template : _.template("""
    <div class="row">
      <h2 class="col-lg-5 col-xs-12"><%= title %></h2>
      <div class="col-lg-7 col-xs-12 picker"></div>
    </div>
    <div class="modal fade" id="modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="overflow: hidden"></div>
  """)


  events :

    "click .edit-time" : "editTime"


  initialize : ->

    @groupByIterator = null
    @currentDate = moment()
    @monthPicker = new MonthPicker()


  createColumns : (ExtendedCell, MinimalHeaderCell) ->

    columns = [
      name: "issue"
      label: "Issue"
    ,
      name: "sum"
      label: "&sum;"
    ]

    _.range(1, @currentDate.endOf("month").date() + 1).forEach( (d) ->
      columns.push(
        name: d
        label: Utils.zeroPad(d)
      )
    )

    for aColumn in columns
      aColumn.editable = false
      aColumn.cell = ExtendedCell
      aColumn.sortable = false
      aColumn.headerCell = MinimalHeaderCell

    return columns


  createGrid : ->

    { MinimalHeaderCell, StylableRow, ExtendedCell } = BackgridModifications()

    columns = @createColumns(ExtendedCell, MinimalHeaderCell)

    return new Backgrid.Grid(
      columns: columns
      collection: new Backbone.Collection(@model.data)
      row: StylableRow
      className: "table table-hover table-bordered table-striped responsive"
    )


  render : ->

    @monthPicker.model = @currentDate

    @$el.append(@template(
      title : @model.title
    ))

    grid = @createGrid()

    @$el.append(grid.render().$el)

    @monthPicker.render()
    @$el.find(".picker").append(@monthPicker.el)

    @popup = @$el.find(".popup")


  addIssueTooltips : (controller) ->

    $("[rel=tooltip").each( (index, element) ->
      $el = $(element)

      [repo, issue] = [$el.data("repo"), $el.data("issue")]

      controller.getIssueTitle(repo, issue).done( (issueTitle) ->


        if issueTitle.length > 53
          # display full name in tooltip

          $el.tooltip(
            "placement" : "right"
            "title" : issueTitle
          )

          issueTitle = issueTitle.slice(0, 50) + "..."

        $el.parent().append("  " + issueTitle)

      )
    )