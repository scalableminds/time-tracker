### define 
jquery : $
bootstrap : bootstrap
controller/controller : Controller
underscore : _
###

class ProjectReportController extends Controller

  cellClass : ""
  
  groupByIterator : (time) -> return time.userGID
  groupByIteratorToString : (time) -> @users[@groupByIterator time]

  
  requestData : ->

    return jsRoutes.controllers.TimeEntryController.showTimesForInterval(@currentDate.year(), @currentDate.month()+1).ajax().then (data) =>
           
      projects = @groupByProjects(data)

      projects = @addDateProperties(projects)

      @model =
        data : projects
        title : "Project Report"


  groupByProjects : (data) ->

    ### will generate something like:
        {
          projects : {
            philippotto/ttest : [
              # each element represents a time logged for an user
              {
                duration : 5,
                issue : Object,
                timestamp: 1372347821934,
                userGID : "2134213"
              },
              {...}
            ],
          }
          tmbo/test : {}
          }
        }
    ###

    projects = {}

    for user in data
      userID = user.userGID
      @users[userID] = user.nick

      for time in user.times
        projectName = time.issue.project
        
        if not projects[projectName]
          projects[projectName] = []

        p = projects[projectName]
        p.push time


    return projects
