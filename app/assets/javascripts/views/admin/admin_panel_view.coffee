### define
jquery : $
underscore : _
backbone.marionette : Marionette
./billing_rates_panel_view : BillingRatesPanelView
./repository_panel_view : RepositoryPanelView
./info_panel_view : InfoPanelView
###

class AdminPanelView extends Backbone.Marionette.Layout

  template: _.template("""
    <div class="admin">
      <section class="row">
        <div class="col-lg-12" id="repository_panel"></div>
      </section>
    <div>
  """)

  regions:
    billingRatesPanel: "#billing_rates_panel"
    repositoryPanel: "#repository_panel"
    infoPanel: "#info_panel"

  initialize: ->

    #Set up sub-views
    #@billingRatesPanelView = new BillingRatesPanelView()
    #@infoPanelView = new InfoPanelView()
    @repositoryPanelView = new RepositoryPanelView()

    @listenTo(@, "render", @afterRender)


  afterRender: ->

    # subviews
    #@billingRatesPanel.show(@billingRatesPanelView)
    #@infoPanel.show(@infoPanelView)
    @repositoryPanel.show(@repositoryPanelView)


