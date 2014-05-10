### define
underscore : _
backbone: backbone
moment: moment
###

class LogTimeModel extends Backbone.Model

  defaults :
    issueNumber : 0
    dateTime : moment()

  url : ->
    "/api/repos/#{@get("id")}/issues/#{@get("issueNumber")}"


  initialize : (options) ->

    if options
      {repositoryId, issueNumber} = options
      @set(
        id : repositoryId
        issueNumber : issueNumber
      )

