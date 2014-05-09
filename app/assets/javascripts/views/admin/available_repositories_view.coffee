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
      <div class="col-sm-5">
        <select name="repository" class="form-control"></select>
      </div>
      <div class="col-sm-5">
        <div class="input-group">
          <span class="input-group-addon">
            <input type="checkbox" id="enableIssueLink">
          </span>
          <div class="form-control">
            Would you like to add links to all your repositories pointing to the time tracker?
             <a href="/faq" title="What is this?"><i class="fa fa-question-circle"></i></a>
          </div>
        </div>
        <div class="input-group">
          <span class="input-group-addon"><i class="fa fa-key"></i></span>
          <input class="form-control" type="text" id="inputAccess" name="accessToken" required="" value="" placeholder="Access Token">
        </div>
      </div>
      <div class="col-sm-2">
        <button type="button" class="btn btn-block btn-default">Add</button>
      </div>
    </div>
  """)

  itemView: AvailableRepositoriesItemView
  itemViewContainer: "select"

  events:
    "click button": "addItem"

  ui :
    "repoName" : "select"
    "repoAccessToken" : "input"

  initialize: ->

    @collection = new AvailableRepositoriesCollection()
    @collection.fetch(
      data :
        isAdmin : true
    )


  addItem: ->

    @trigger("newItem",
      name : @ui.repoName.val()
      accessToken : @ui.repoAccessToken.val()
      usesIssueLinks : false
    )
