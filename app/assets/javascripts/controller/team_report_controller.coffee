### define
jquery : $
bootstrap : bootstrap
underscore : _
controller/controller : Controller
###


class TeamReportController extends Controller

  cellClass : ""

  groupByIterator : (time) -> return time.issue.project
  getSecondLevelLabel : (time) -> @groupByIterator(time)

  requestData : ->

    return jsRoutes.controllers.TimeEntryController.showTimesForInterval(@currentDate.year(), @currentDate.month()+1).ajax().then (data) =>

      data = _.groupBy(data, "nick")
      data = _.forOwn(data, (value, key) -> data[key] = _.flatten(_.pluck(value, "times")))

      data = @addDateProperties(data)

      @model =
        data : data
        title : "Team Report"