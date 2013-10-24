### define 
jquery : $
bootstrap : bootstrap
underscore : _
../report_table : ReportTable
../utils : Utils
###


class Controller


  constructor : ->

    @users = {}
    @loadAndDisplay moment()

  loadAndDisplay : (@currentDate) ->
    
    @requestData().done =>
      @displayModel()


  displayModel : ->

    @instantiateView()
    @view.render()

    $("#main-container .container").empty().append(@view.el)

    @view.monthPicker.on "change", (event) =>
      @loadAndDisplay(@view.monthPicker.model)
  

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