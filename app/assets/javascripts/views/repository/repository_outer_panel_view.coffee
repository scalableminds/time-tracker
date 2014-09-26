### define
underscore : _
backbone.marionette : Marionette
./added_repositories_view : AddedRepositoriesView
./new_repository_view : NewRepositoryView
###

class RepositoryOuterPanelView extends Backbone.Marionette.Layout

  className : "admin"
  template: _.template("""
    <section class="row">
      <div class="col-lg-12">
        <section id="added-repositories" class="well">
        </section>
      </div>
    </section>
    <section id="new-repository"></section>
    </section>
  """)

  regions:
    addedRepositories : "#added-repositories"
    newRepository     : "#new-repository"


  initialize: ->

    #Set up sub-views
    @addedRepositoriesView = new AddedRepositoriesView()
    @newRepositoryView = new NewRepositoryView()

    @listenTo(@newRepositoryView, "newRepo", @addNewRepository)


  onRender: ->

    @addedRepositories.show(@addedRepositoriesView)
    @newRepository.show(@newRepositoryView)


  addNewRepository: (newRepo) ->

    @addedRepositoriesView.collection.create(newRepo, wait : true)

