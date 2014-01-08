 ### define
underscore : _
backbone.marionette : Marionette
./active_repositories_item : ActiveRepositoriesItem
models/admin/active_repositories_collection : ActiveRepositoriesCollection
###

class ActiveRepositories extends Backbone.Marionette.CompositeView

  template: _.template("""
    <header class="row">
      <h3 class="col-lg-12">Used Repositories</h3>
    </header>
    <div class="table-responsive">
      <table class="table table-striped">
	<thead>
	  <tr>
	    <th>#</th>
	    <th>Name</th>
	    <th>Access-Token</th>
	    <th>Admin Ids</th>
	  </tr>
	</thead>
	<tbody>
	</tbody>
      </table>
    </div>
  """)

  itemView: ActiveRepositoriesItem
  itemViewContainer: "tbody"

  initialize: ->

    @collection = new ActiveRepositoriesCollection()
