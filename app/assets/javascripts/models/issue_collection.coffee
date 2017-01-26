Backbone = require("backbone")

class IssueCollection extends Backbone.Collection

  url : -> "/api/issues/#{@project}"

  initialize : (options) ->
    @project = options.project

  modelId : (attrs) -> return attrs.reference.number

  getIssueById : (id) ->
    return @find((issue) -> issue.get("reference").number == id)


module.exports = IssueCollection