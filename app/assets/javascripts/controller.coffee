### define 
jquery : $
bootstrap : bootstrap
report_table : ReportTable
###


class Controller


  constructor : ->

    @loadAndDisplay 2013, 8
  

  loadAndDisplay : (@year, @month) ->
    
    @requestData().done =>
      @displayModel()


  displayModel : ->

    @instantiateView()
    @view.render()

    $("#main-container .container").empty().append(@view.el)

    @view.monthPicker.on "change", (event) =>
      @loadAndDisplay(event.year(), event.month() + 1)
  
  instantiateView : ->

    @view = new ReportTable()
    @view.model = @model
    @view.currentDate = moment([@year, @month - 1, 1])

    @view.groupByIterator = @groupByIterator
    @view.cellClass = @cellClass

  requestData : ->

    # subclass responsibility



