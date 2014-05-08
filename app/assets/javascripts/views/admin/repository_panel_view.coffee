### define
underscore : _
backbone.marionette : Marionette
./available_repositories_view : AvailableRepositoriesView
./active_repositories_view : ActiveRepositoriesView
###

class RepositoryPanelView extends Backbone.Marionette.Layout

  template: _.template("""
    <section id="available_repositories">
    </section>
    <section id="active_repositories">
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


  render: ->

    @$el.html(@template())

    # subviews
    @availableRepositories.show(@availableRepositoriesView)
    @activeRepositories.show(@activeRepositoriesView)


  addActiveRepository: ->

    #TODO fetch the collection again from the server
    @activeRepositoriesView.collection.add({id: Math.random(), repository: "scalableminds/auth-proxy", accessToken: 1234567, adminId: 123})

