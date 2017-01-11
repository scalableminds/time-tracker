ActiveRepositoriesCollection = require("models/admin/active_repositories_collection")
ActiveRepositoriesItemView = require("./active_repositories_item_view")
Marionette = require("marionette")
_ = require("underscore")

class ActiveRepositoriesView extends Marionette.CompositeView

  template: _.template("""
    <header class="row">
      <h3 class="col-lg-12">Tracking-enabled Repositories</h3>
    </header>
    <div class="table-responsive">
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Name</th>
            <th>Repository Admins</th>
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
    @collection.fetch()

module.exports = ActiveRepositoriesView