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

      @view = new ReportTable()
      @view.model = @model
      
      @view.currentDate = moment([@year, @month - 1, 1])
      
      @view.render()

      $("#main-container .container").empty().append(@view.el)

      @view.monthPicker.on "change", (event) =>
        @loadAndDisplay(event.year(), event.month() + 1)
      

  requestData : ->

    return jsRoutes.controllers.TimeEntryController.showTimeForUser(@year, @month).ajax().then (json) =>
      console.log "json", json

      for currentProjectName, currentProject of json.projects
        for currentLog in currentProject
          currentLog.date = new Date(currentLog.timestamp)

      @model = json