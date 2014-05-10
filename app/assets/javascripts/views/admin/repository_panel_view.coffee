### define
underscore : _
backbone.marionette : Marionette
./available_repositories_view : AvailableRepositoriesView
./active_repositories_view : ActiveRepositoriesView
###

class RepositoryPanelView extends Backbone.Marionette.Layout

  template: _.template("""
    <section id="available_repositories" class="well">
    </section>
    <section id="active_repositories" class="well">
    </section>
  """)

  regions:
    availableRepositories: "#available_repositories"
    activeRepositories: "#active_repositories"


  initialize: ->

    #Set up sub-views
    @availableRepositoriesView = new AvailableRepositoriesView()
    @activeRepositoriesView = new ActiveRepositoriesView()

    @listenTo(@availableRepositoriesView, "newItem", @addActiveRepository)
    @listenTo(@, "render", @afterRender)

  afterRender: ->

    @availableRepositories.show(@availableRepositoriesView)
    @activeRepositories.show(@activeRepositoriesView)


  addActiveRepository: (newRepository) ->

    @activeRepositoriesView.collection.create(newRepository, wait : true)

