### define
jquery : $
bootstrap : bootstrap
underscore : _
controller/controller : Controller
###


class UserReportController extends Controller

  cellClass : "edit-time"

  issueCache : {}

  groupByIterator : (time) -> return time.issue.number

  getSecondLevelLabel : (time, repo) ->

    issueNumber = @groupByIterator(time)
    $link = "<a rel='tooltip' href='https://github.com/#{repo}/issues/#{issueNumber}' data-repo='#{repo}' data-issue='#{issueNumber}'>" + issueNumber + "</a>"

    return $link

  getIssueTitle : (repo, issueNumber) ->

    unless @issueCache[repo]?
      @issueCache[repo] = $.get("/issues/#{repo}")

    return @issueCache[repo].then( (data) ->

      issue = _.find(data.issues, (info) -> info.number == issueNumber)

      title =
        if issue
          issue.title
        else if issueNumber == 0
          "Issue #0"
        else
          "Issue could not be found."

      return title
    )


  displayModel : ->

    super()
    @view.addIssueTooltips(this)

  requestData : ->

    return jsRoutes.controllers.TimeEntryController.showTimeForUser(@currentDate.year(), @currentDate.month()+1).ajax().then (data) =>

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


