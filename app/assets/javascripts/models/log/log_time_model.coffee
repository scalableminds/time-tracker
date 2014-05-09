### define
underscore : _
backbone: backbone
moment: moment
###

class LogTimeModel extends Backbone.Model

  constructor : (repository = null, issueNumber = 0) ->

    super(
      dateTime : moment()
      repository: repository
      issueNumber : issueNumber
    )

  save : (attributes) ->

    @url = "/api/repos/#{attributes.repository}/issues/#{attributes.issueNumber}"

    super(attributes, {method : "POST"})