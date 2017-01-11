AvailableRepositoriesCollection = require("models/admin/available_repositories_collection")
AvailableRepositoriesItemView = require("./available_repositories_item_view")
Marionette = require("marionette")
_ = require("underscore")

class AvailableRepositoriesView extends Marionette.CompositeView

  template: _.template("""
    <header class="row">
      <h3 class="col-lg-12">Add a New Repository</h3>
    </header>
    <div class="row">
      <div class="col-sm-7 row-spacer">
        <div>
          <select name="repository" class="form-control"></select>
        </div>
        <div class="input-group">
          <span class="input-group-addon">
            <input type="checkbox" id="enableIssueLink">
          </span>
          <div class="form-control">
            Would you like to add links to this repository's issues pointing to the time tracker?
          </div>
        </div>
        <div class="input-group hidden access-token"">
          <span class="input-group-addon"><i class="fa fa-key"></i></span>
          <input class="form-control" type="text" id="input-access-token" name="accessToken" required="" value="" placeholder="Access Token">
        </div>
        <div class="col-sm-3 row">
          <button type="button" class="btn btn-block btn-default">Add</button>
        </div>
      </div>
      <div class="col-sm-5 help">
          <i class="fa fa-question-circle pull-left"></i>
          To enable time-tracking for one of your repositories, please add it here.
          You can choose to automatically add links to the repository's issues, poining to the time tracker for convient tracking within Github's user interface.
          <a href="/faq#auto-link">Learn more.</a>
      </div>
    </div>
  """)

  itemView: AvailableRepositoriesItemView
  itemViewContainer: "select"

  events:
    "click button": "addItem"
    "click input[type=checkbox]" : "toggleAccessToken"

  ui :
    "repoName" : "select"
    "repoAccessToken" : "#input-access-token"
    "enableIssueLink" : "#enableIssueLink"
    "containerAccessToken" : ".access-token"


  initialize: ->

    @collection = new AvailableRepositoriesCollection()
    @collection.fetch(
      data :
        isAdmin : true
    )

  toggleAccessToken : ->

    enableIssueLink = if @ui.enableIssueLink.prop("checked") then true else false
    if enableIssueLink
      @ui.containerAccessToken.removeClass("hidden")
      window.setTimeout (=> @ui.containerAccessToken.addClass("in")), 100
    else
      @ui.containerAccessToken.addClass("hidden")



  addItem: ->

    enableIssueLink = if @ui.enableIssueLink.prop("checked") then true else false
    if enableIssueLink
      accessToken = @ui.repoAccessToken.val()
    else
      accessToken = null

    @trigger("newItem",
      name : @ui.repoName.val()
      usesIssueLinks : enableIssueLink
      accessToken: accessToken
    )

module.exports = AvailableRepositoriesView
