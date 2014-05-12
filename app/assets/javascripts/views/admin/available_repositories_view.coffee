### define
underscore : _
backbone.marionette : Marionette
./available_repositories_item_view : AvailableRepositoriesItemView
models/admin/available_repositories_collection : AvailableRepositoriesCollection
###

class AvailableRepositoriesView extends Backbone.Marionette.CompositeView

  template: _.template("""
    <header class="row">
      <h3 class="col-lg-12">Add a New Repository</h3>
    </header>
    <div class="row">
      <div class="col-sm-7">
        <select name="repository" class="form-control"></select>
      </div>
    </div>
    <div class="row">
      <div class="col-sm-7">
        <div class="input-group">
          <span class="input-group-addon">
            <input type="checkbox" id="enableIssueLink">
          </span>
          <div class="form-control">
            Would you like to add links to this repository's issues pointing to the time tracker?
             <a href="/faq#auto-link" title="What is this?"><i class="fa fa-question-circle"></i></a>
          </div>
        </div>
      </div>
    </div>
    <div class="row fade hidden access-token">
      <div class="col-sm-7">
        <div class="input-group">
          <span class="input-group-addon"><i class="fa fa-key"></i></span>
          <input class="form-control" type="text" id="input-access-token" name="accessToken" required="" value="" placeholder="Access Token">
        </div>
      </div>
    </div>
    <div class="row">
      <div class="col-sm-3">
        <button type="button" class="btn btn-block btn-default">Add</button>
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
