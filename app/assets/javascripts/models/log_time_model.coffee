### define
underscore : _
backbone: backbone
moment: moment
###

class LogTimeModel extends Backbone.Model

  constructor : (repository = null, issueNumber = 0) ->

    super(
      timestamp : moment()
      repository: repository
      issueNumber : issueNumber
    )

  save : (attributes) ->

    @url = "/repos/#{repository}/issues/#{issueNumber}"
    super.save(attributes, {method : "POST"})