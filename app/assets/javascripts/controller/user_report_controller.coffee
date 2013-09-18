### define 
jquery : $
bootstrap : bootstrap
underscore : _
controller/controller : Controller
###


class UserReportController extends Controller

  cellClass : "edit-time"

  groupByIterator : (time) -> return time.issue.number
  groupByIteratorToString : (time) -> @groupByIterator(time)

  requestData : ->

    return jsRoutes.controllers.TimeEntryController.showTimeForUser(@currentDate.year(), @currentDate.month()).ajax().then (data) =>

      projects = @addDateProperties(data.projects)

      @model = 
        data : projects
        title : data.nick

      ###
      model will hold information like
      {
        userGID: "2486553",
        name: "",
        email: null,
        projects: {
          philippotto/ttest: [
            # each element represents a time logged for an issue
            {
              issue: {
                project: "philippotto/ttest",
                number: 1
              },
              duration: 17,
              userGID: "2486553",
              timestamp: 1376822283824
            },
            {},
            {}
          ],
          tmbo/test: [...]
        }
      }
      ###


