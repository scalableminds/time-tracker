### define
underscore : _
backbone.marionette : Marionette
./available_repositories : AvailableRepositoriesView
./active_repositories : ActiveRepositoriesView
###

class RepositoryPanel extends Backbone.Marionette.Layout

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


  render: ->

    @$el.html(@template())

    # subviews
    @availableRepositories.show(@availableRepositoriesView)
    @activeRepositories.show(@activeRepositoriesView)


  addItem: ->

    if @ui.$inputProjectName[0].checkValidity() and @ui.$inputRate[0].checkValidity()
      projectName = @ui.$inputProjectName.val()
      projectRate = @ui.$inputRate.val()
      @collection.add({project: projectName, rate: projectRate})

      @ui.$sectionCreateNew.removeClass("in")
      @ui.$sectionCreateNew.addClass("hidden")
