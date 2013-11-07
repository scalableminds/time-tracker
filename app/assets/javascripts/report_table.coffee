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


  createColumns : ->

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

    return columns

  createGrid : ->
    
    columns = @createColumns()

    options = 
      "cellOnClick" : @cellOnClick

    { MinimalHeaderCell, StylableRow, ClickableCell } = BackgridModifications(options)


    for aColumn in columns
      aColumn.editable = false
      aColumn.cell = ClickableCell
      aColumn.sortable = false
      aColumn.headerCell = MinimalHeaderCell

    console.log(@model.data, "@model.data")

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

    grid.$el.find("tr").trigger("style")

    @monthPicker.render()
    @$el.find(".picker").append(@monthPicker.el)

    @popup = @$el.find(".popup")


  cellOnClick: ->

    day = @el.cellIndex - 1
    entriesDaysGroups = @model.attributes.entriesDaysGroups
    
    # existence of entriesDaysGroups should ensure that we aren't on a sectionRow or in tfoot (where this event shouldn't be triggered)

    if day > 0 and entriesDaysGroups

      event.stopPropagation()

      dayEntries = entriesDaysGroups[day]

      detailsTable = new DetailsTable()
      detailsTable.model = dayEntries
      detailsTable.render()

      $("#modal").html(detailsTable.el).modal("show")
