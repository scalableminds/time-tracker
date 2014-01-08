 ### define
underscore : _
backbone.marionette : Marionette
./available_repositories_item : AvailableRepositoriesItem
models/admin/available_repositories_collection : AvailableRepositoriesCollection
###

class AvailableRepositories extends Backbone.Marionette.CompositeView

  template: _.template("""
    <header class="row">
      <h2 class="col-lg-12">Add a new repository</h2>
    </header>
    <div class="row">
      <div class="col-lg-5">
	<select name="repository" class="form-control"></select>
      </div>
      <div class="col-lg-5 input-group">
	<span class="input-group-addon"><i class="fa fa-key"></i></span>
	<input class="form-control" type="text" id="inputAccess" name="accessToken" required="" value="" placeholder="Access Token">
      </div>
      <div class="col-lg-2">
	<button type="button" class="btn btn-block btn-default">Add</button>
      </div>
    </div>
  """)

  itemView: AvailableRepositoriesItem
  itemViewContainer: "select"

  initialize: ->

    @collection = new AvailableRepositoriesCollection()

	#<label class="col-lg-2 control-label" for="inputRepo">Repository</label>
  #<form action="/admin/repositories" method="POST" class="form-horizontal" role="form">