### define
underscore : _
backbone.marionette : Marionette
./added_repositories_item_view : AddedRepositoriesItemView
models/repository/added_repositories_collection : AddedRepositoriesCollection
###

class AddedRepositoryView extends Backbone.Marionette.CompositeView

  template: _.template("""
    <header class="row">
      <h3 class="col-lg-12">Added None-Github Repositories</h3>
    </header>
    <div class="table-responsive">
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Name</th>
            <th>Repository Admins</th>
            <th>Repository Users</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
    </div>
  """)

  itemView: AddedRepositoriesItemView
  itemViewContainer: "tbody"

  initialize : ->

    @collection = new AddedRepositoriesCollection()
    @collection.fetch()

