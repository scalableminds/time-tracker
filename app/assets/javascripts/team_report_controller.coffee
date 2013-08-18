### define 
jquery : $
bootstrap : bootstrap
controller : Controller
team_report_table : TeamReportTable
###

class TeamReportController extends Controller

  cellClass : ""
  
  groupByIterator : (time) -> return time.issue.project
  groupByIteratorToString : (time) -> @groupByIterator time
  
  requestData : ->

    return jsRoutes.controllers.TimeEntryController.showTimesForInterval(@year, @month).ajax().then (data) =>
      
      dic = {}

      for user in data
        dic[user.name] = user.times



      @model = {projects : dic}
      console.log "data", data




      for currentProjectName, currentProject of @model.projects
        for currentLog in currentProject
          currentLog.date = new Date(currentLog.timestamp)

      return @model



# class TeamReportController extends Controller

#   requestData : ->

#     return jsRoutes.controllers.TimeEntryController.showTimesForInterval(@year, @month).ajax().then (data) =>
           
#       @model =  data

#       for currentProjectName, currentProject of @model.projects
#         for currentLog in currentProject
#           currentLog.date = new Date(currentLog.timestamp)

#   instantiateView : ->

#     @view = new TeamReportTable()

#     @view.model = @model
#     @view.users = @users
#     @view.currentDate = moment([@year, @month - 1, 1])


#     # view.render()

#     # $("#main-container .container").empty().append(view.el)

#     # view.monthPicker.on "change", (event) =>
#     #   @loadAndDisplay(event.year(), event.month() + 1)