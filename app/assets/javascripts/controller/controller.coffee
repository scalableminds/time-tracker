### define 
jquery : $
bootstrap : bootstrap
underscore : _
../report_table : ReportTable
../table_view : TableView
../utils : Utils

backgrid : Backgrid

###


class Controller


  constructor : ->

    @users = {}
    @loadAndDisplay moment()

  loadAndDisplay : (@currentDate) ->
    
    @requestData().done =>
      @displayModel()


  displayModel : ->

    console.warn("exiting early in displayModel")
    # return


    @instantiateView()
    @view.render()


    console.warn("add empty again")
    $("#main-container .container").empty().append(@view.el)

    @testTableHierarchy()


    @view.monthPicker.on "change", (event) =>
      @loadAndDisplay(@view.monthPicker.model)

  
  testTableHierarchy: ->

    MinimalHeaderCell = Backgrid.HeaderCell.extend(

      render: -> 
        @$el.empty()
        $label = @column.get("label")
        @$el.append($label)
        @delegateEvents()
        return @
      
    )
    

    ClickableRow = Backgrid.Row.extend(
      
      events: { "click" : "onClick" }
      
      onClick: ->
        console.log("this", @)
        window.test = @
        @$el.addClass("project-row")
        Backbone.trigger("rowclicked", @model)

    )

    Backbone.on("rowclicked", (model) ->
      console.log("model", model)
    )


    columns = [
      name: "issue"
      label: "Issue"
      editable: false
      cell: "string"
      sortable: false
      headerCell: MinimalHeaderCell
    ,
      name: "sum"
      label: "&sum;"
      editable: false
      sortable: false
      cell: "string"
      headerCell: MinimalHeaderCell
    ]

    data = @prepareModel()

    _.range(1, @currentDate.endOf("month").date() + 1).forEach( (d) ->
      columns.push(
        name: d
        label: Utils.zeroPad(d)
        editable: false
        sortable: false
        cell: "string"
        headerCell: MinimalHeaderCell
      )
    )


    console.log("data", data)

    dataCollection = new Backbone.Collection(data)
    
    grid = new Backgrid.Grid(
      columns: columns
      collection: dataCollection
      row: ClickableRow
      className: "table table-hover table-bordered table-striped"
    )

    $("div.report-table").append(grid.render().$el)


  instantiateView : ->

    @view = new ReportTable()
    @view.model = @model
    @view.currentDate = @currentDate
    @view.table = @prepareTable()
    @view.groupByIterator = @groupByIterator
    

  requestData : ->

    # subclass responsibility


  addDateProperties : (model) ->

    for currentProjectName, currentProject of model
      for currentLog in currentProject
        currentLog.date = new Date(currentLog.timestamp)

    model


  prepareModel : ->

    table = []
    
    # thead
    daysRange = _.range(1, @currentDate.endOf("month").date() + 1)

    # headerRow = 
    #   "issue" : "Issue"
    #   "sum"   : "&sum;"
    
    # _.map(daysRange, (a) ->
    #   headerRow[a] = Utils.zeroPad(a)
    # )
    
    # table.push(headerRow)

    #tbody
    for element, elementEntries of @model.data
      
      elementDaysGroups = _.groupBy(elementEntries, (a) -> moment(a.date).date())

      daySums = _.map(daysRange, (day) -> Utils.sum(_.map(elementDaysGroups[day] ? [], (a) -> a.duration)))

      sectionHeaderRow = 
        "issue" : element
        "sum" : Utils.minutesToHours(Utils.sum(daySums))

      _.map(daySums, (sum, index) ->
        sectionHeaderRow[index] = Utils.minutesToHours(sum) || ""
      )

      table.push(sectionHeaderRow)



      _.forOwn(_.groupBy(elementEntries, @groupByIterator),
        (entries) =>

          entriesDaysGroups = _.groupBy(entries, (a) -> moment(a.date).date())
          
          entry = @groupByIteratorToString entries[0]

          currentRow =
            "issue" : entry
            "sum" : Utils.minutesToHours(Utils.sum(_.map(entries, "duration")))
          

          _.map(daysRange, (day) =>
              value = Utils.minutesToHours(Utils.sum(
                _.map(entriesDaysGroups[day] ? [], (a) => a.duration)
              )) || ""
              
              currentRow[day] = value
          )


          table.push currentRow
      )

    #tfoot
    allEntries = _.flatten(_.values(@model.data))
    allDaysGroups = _.groupBy(allEntries, (a) -> moment(a.date).date())

    footerRow =
      "issue" : "&sum;"
      "sum" :  Utils.minutesToHours(Utils.sum(_.map(allEntries, "duration")))

    _.map(daysRange, (day) ->
        footerRow[day] = Utils.minutesToHours(Utils.sum(_.map(allDaysGroups[day] ? [], (a) -> a.duration))) || ""
    )

    table.push(footerRow)


    return table




  prepareTable : ->

    table = []

    Row = (cells, groupByIdentifier = "", entityIdentifier = "", className = "") -> { cells, groupByIdentifier, entityIdentifier, className }
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

      daySums = _.map(daysRange, (day) -> Utils.sum(_.map(elementDaysGroups[day] ? [], (a) -> a.duration)))

      table.push(
        Row(
          [
            Cell(element)
            # , Cell(Utils.sum(_.map(elementEntries, "duration")))
            Cell(Utils.minutesToHours(Utils.sum(daySums)))
          ].concat(_.map(daySums, (a) -> Cell(Utils.minutesToHours(a) || ""))),
          "", "",
          "project-row"
        )
      )

      _.forOwn(_.groupBy(elementEntries, @groupByIterator),
        (entries) =>

          entriesDaysGroups = _.groupBy(entries, (a) -> moment(a.date).date())
          
          entry = @groupByIteratorToString entries[0]

          leftCells = [
            Cell(entry)
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
          aRow = Row(leftCells.concat(rightCells), element, entry)
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
      [ 
        Cell("&sum;")
        # Cell("")
        Cell(Utils.minutesToHours(Utils.sum(_.map(allEntries, "duration"))))
      ].concat rightCells
    )


    return table