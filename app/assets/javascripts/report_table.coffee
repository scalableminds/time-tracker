### define
jquery : $
underscore : _
backbone : Backbone
details_table : DetailsTable
./month_picker : MonthPicker
./utils : Utils
backgrid : Backgrid
./backgrid_modifications : BackgridModifications
###

class ReportTable extends Backbone.View

  className : "report-table"

  template : _.template("""
    <div class="row">
      <h2 class="col-lg-8"><%= title %></h2>
      <div class="col-lg-4 picker"></div>
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
      className: "table table-hover table-bordered table-striped"
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


  addIssueTooltips : ->

    issueCache = {}

    $("[rel=tooltip").each( (index, element) ->

      $element = $(element)

      repo = $element.data("repo")
      issueNumber = $element.data("issue")

      unless issueCache[repo]?
        issueCache[repo] = $.get("/issues/#{repo}")


      issueCache[repo].then( (data) ->
        
        issue = _.find(data.issue, (info) -> info.number == issueNumber)

        $element.tooltip(
          "placement" : "right"
          "title" : 
            if issue 
              issue.title
            else if issueNumber == 0
              "Issue #0"
            else
              "Issue could not be found."

        )

      )
    )