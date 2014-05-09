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

    @url = "/api/repos/#{attributes.repository}/issues/#{attributes.issueNumber}"

    #make sure the timestamp gets synced as unix timestamp
    unixTimestamp = moment(@get("timestamp")).unix() * 1000
    @set("timestamp", unixTimestamp)

    super(attributes, {method : "POST"})