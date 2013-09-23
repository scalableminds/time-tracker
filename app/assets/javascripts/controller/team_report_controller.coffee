### define 
jquery : $
bootstrap : bootstrap
underscore : _
controller/controller : Controller
###


class TeamReportController extends Controller

  cellClass : ""
  
  groupByIterator : (time) -> return time.issue.project
  groupByIteratorToString : (time) -> @groupByIterator time
  
  requestData : ->

    return jsRoutes.controllers.TimeEntryController.showTimesForInterval(@currentDate.year(), @currentDate.month()).ajax().then (data) =>
      
      data = _.groupBy(data, "nick")
      data = _.forOwn(data, (value, key) -> data[key] = _.flatten(_.pluck(value, "times")))

      data = @addDateProperties(data)

      @model = 
        data : data
        title : "Team Report"