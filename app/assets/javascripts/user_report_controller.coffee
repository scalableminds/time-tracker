### define 
jquery : $
bootstrap : bootstrap
controller : Controller
###


class UserReportController extends Controller

  cellClass : "edit-time"

  groupByIterator : (time) -> return time.issue.number
  groupByIteratorToString : (time) -> @groupByIterator(time)

  requestData : ->

    return jsRoutes.controllers.TimeEntryController.showTimeForUser(@year, @month).ajax().then (data) =>
      console.log "data", data

      for currentProjectName, currentProject of data.projects
        for currentLog in currentProject
          currentLog.date = new Date(currentLog.timestamp)

      @model = data

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


