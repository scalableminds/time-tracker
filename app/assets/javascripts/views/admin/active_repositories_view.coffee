### define
underscore : _
backbone.marionette : Marionette
./active_repositories_item_view : ActiveRepositoriesItemView
models/admin/active_repositories_collection : ActiveRepositoriesCollection
###

class ActiveRepositoriesView extends Backbone.Marionette.CompositeView

  template: _.template("""
    <header class="row">
      <h3 class="col-lg-12">Tracking-enabled Repositories</h3>
    </header>
    <div class="table-responsive">
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Name</th>
            <th>Admin Ids</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
    </div>
  """)

  itemView: ActiveRepositoriesItemView
  itemViewContainer: "tbody"

  initialize: ->

    @collection = new ActiveRepositoriesCollection()

