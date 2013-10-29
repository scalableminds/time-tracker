### define
jquery : $
underscore : _
backbone : Backbone
details_table : DetailsTable
./month_picker : MonthPicker
./utils : Utils
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


  createGrid : ->

    # avoids ugly <a> tags in header
    MinimalHeaderCell = Backgrid.HeaderCell.extend(

      render: -> 

        @$el.empty()
        $label = @column.get("label")
        @$el.append($label)
        @delegateEvents()
        return @
      

    )
    
    # allows for styled section-rows
    StylableRow = Backgrid.Row.extend(
      
      events:
        "style" : "onStyle"
      

      onStyle: ->
        className = @model.attributes.className
        if className
          @$el.addClass(className)


    )


    ClickableCell = Backgrid.Cell.extend(
      
      events:

        "click" : "onClick"
      

      onClick: ->

        day = @el.cellIndex - 1
        entriesDaysGroups = @model.attributes.entriesDaysGroups
        
        # existence of entriesDaysGroups should ensure that we aren't on a sectionRow or in tfoot
        console.warn("check if we are in user-view?")
        
        if day > 0 and entriesDaysGroups

          event.stopPropagation()

          dayEntries = entriesDaysGroups[day]

          console.log("@model.attributes.entriesDaysGroups",  dayEntries)
          # Backbone.trigger("rowclicked", @model)
                  

          detailsTable = new DetailsTable()
          detailsTable.model = dayEntries
          detailsTable.render()

          $("#modal").html(detailsTable.el).modal("show")

    )
  

    # Backbone.on("rowclicked", (model) ->
    #   console.log("model", model)
    # )


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
      aColumn.cell = ClickableCell
      aColumn.sortable = false
      aColumn.headerCell = MinimalHeaderCell


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

    console.warn("right way and time to trigger this?")
    grid.$el.find("tr").trigger("style")


    @monthPicker.render()
    @$el.find(".picker").append(@monthPicker.el)

    @popup = @$el.find(".popup")