### define 
jquery : $
bootstrap : bootstrap
controller : Controller
###

class TeamReportController extends Controller

  cellClass : ""
  
  groupByIterator : (time) -> return time.userGID


  requestData : ->

    return jsRoutes.controllers.TimeEntryController.showTimesForInterval(@year, @month).ajax().then (data) =>
           
      @model = @groupByProjects data

      for currentProjectName, currentProject of @model.projects
        for currentLog in currentProject
          currentLog.date = new Date(currentLog.timestamp)

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

    console.log data
    projects = {}

    for user in data
      userID = user.userGID
      for time in user.times
        projectName = time.issue.project
        
        if not projects[projectName]
          projects[projectName] = []

        p = projects[projectName]
        p.push time


    console.log "projects", projects
    return {"projects" : projects}
