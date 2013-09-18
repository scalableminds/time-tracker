### define 
jquery : $
bootstrap : bootstrap
underscore : _
../report_table : ReportTable
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
    @view.users = @users
    @view.currentDate = @currentDate

    @view.groupByIterator = @groupByIterator
    @view.groupByIteratorToString = @groupByIteratorToString
    @view.cellClass = @cellClass


  requestData : ->

    # subclass responsibility


  addDateProperties : (model) ->

    for currentProjectName, currentProject of model
      for currentLog in currentProject
        currentLog.date = new Date(currentLog.timestamp)

    model


