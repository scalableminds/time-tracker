### define 
jquery : $
bootstrap : bootstrap
controller/controller : Controller
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

      @model = {data : dic}
      console.log "data", data

      for currentProjectName, currentProject of @model.data
        for currentLog in currentProject
          currentLog.date = new Date(currentLog.timestamp)

      return @model