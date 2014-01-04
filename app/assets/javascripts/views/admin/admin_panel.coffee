### define
jquery : $
underscore : _
backbone.marionette : Marionette
./billing_rates_panel : BillingRatesPanelView
./repository_panel : RepositoryPanelView
./info_panel : InfoPanelView
###

class AdminPanel extends Backbone.Marionette.Layout

  template: _.template("""
    <section class="row">
      <div class="col-lg-5 well" id="info_panel"></div>
      <div class="col-lg-6 col-md-offset-1 well" id="billing_rates_panel"></div>
    </section>
    <section class="row">
      <div class="col-lg-12 well" id="repository_panel"></div>
    </section>
  """)

  regions:
    billingRatesPanel: "#billing_rates_panel"
    repositoryPanel: "#repository_panel"
    infoPanel: "#info_panel"


  initialize: ->

    #Set up sub-views
    @billingRatesPanelView = new BillingRatesPanelView()
    @infoPanelView = new InfoPanelView()
    @repositoryPanelView = new RepositoryPanelView()


  render: ->

    @$el.html(@template())

    # subviews
    @billingRatesPanel.show(@billingRatesPanelView)
    @infoPanel.show(@infoPanelView)
    @repositoryPanel.show(@repositoryPanelView)
