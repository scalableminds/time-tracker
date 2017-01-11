ActiveRepositoriesView = require("./active_repositories_view")
AvailableRepositoriesView = require("./available_repositories_view")
Marionette = require("marionette")
_ = require("underscore")

class RepositoryPanelView extends Marionette.Layout

  template: _.template("""
    <section id="available-repositories" class="well">
    </section>
    <section id="active-repositories" class="well">
    </section>
  """)

  regions:
    availableRepositories: "#available-repositories"
    activeRepositories: "#active-repositories"


  initialize: ->

    #Set up sub-views
    @availableRepositoriesView = new AvailableRepositoriesView()
    @activeRepositoriesView = new ActiveRepositoriesView()

    @listenTo(@availableRepositoriesView, "newItem", @addActiveRepository)


  onRender: ->

    @availableRepositories.show(@availableRepositoriesView)
    @activeRepositories.show(@activeRepositoriesView)


  addActiveRepository: (newRepository) ->

    @activeRepositoriesView.collection.create(newRepository, wait : true)

module.exports = RepositoryPanelView