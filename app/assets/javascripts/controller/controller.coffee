### define 
jquery : $
bootstrap : bootstrap
underscore : _
../report_table : ReportTable
../utils : Utils
details_table : DetailsTable
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

    @instantiateView()
    @view.render()

    $("#main-container .container").empty().append(@view.el)

    @view.monthPicker.on "change", (event) =>
      @loadAndDisplay(@view.monthPicker.model)

  
  instantiateView : ->

    @view = new ReportTable()
    @view.model =
      "title" : @model.title
      "data" : @prepareModel()

    @view.currentDate = @currentDate
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
    
    daysRange = _.range(1, @currentDate.endOf("month").date() + 1)


    #tbody
    for element, elementEntries of @model.data
      
      elementDaysGroups = _.groupBy(elementEntries, (a) -> moment(a.date).date())

      daySums = _.map(daysRange, (day) -> Utils.sum(_.map(elementDaysGroups[day] ? [], (a) -> a.duration)))

      sectionHeaderRow = 
        "issue" : element
        "sum" : Utils.minutesToHours(Utils.sum(daySums))
        "className" : "project-row"

      _.map(daySums, (sum, index) ->
        sectionHeaderRow[index + 1] = Utils.minutesToHours(sum) || ""
      )

      table.push(sectionHeaderRow)


      _.forOwn(_.groupBy(elementEntries, @groupByIterator),
        (entries) =>

          entriesDaysGroups = _.groupBy(entries, (a) -> moment(a.date).date())
          
          entry = @groupByIteratorToString(entries[0])

          currentRow =
            "issue" : entry
            "sum" : Utils.minutesToHours(Utils.sum(_.map(entries, "duration")))
            "entriesDaysGroups" : entriesDaysGroups

          _.map(daysRange, (day) =>
              value = Utils.minutesToHours(Utils.sum(
                _.map(entriesDaysGroups[day] ? [], (a) => a.duration)
              )) || ""
              
              currentRow[day] = value
          )


          table.push(currentRow)
      )

    #tfoot
    allEntries = _.flatten(_.values(@model.data))
    allDaysGroups = _.groupBy(allEntries, (a) -> moment(a.date).date())

    footerRow =
      "issue" : "&sum;"
      "sum" :  Utils.minutesToHours(Utils.sum(_.map(allEntries, "duration")))
      "className" : "tfoot"

    _.map(daysRange, (day) ->
        footerRow[day] = Utils.minutesToHours(Utils.sum(_.map(allDaysGroups[day] ? [], (a) -> a.duration))) || ""
    )
    
    table.push(footerRow)


    return table

