### define
jquery : $
underscore : _
backbone.marionette : Marionette
./billing_rates_panel : BillingRatesPanelView
./repository_panel : RepositoryPanelView
###

class AdminPanel extends Backbone.Marionette.Layout

  template: _.template("""
    <h2>Admin Panel</h2>
    <section class="row">
      <div class="col-lg-6 well"></div>
      <div class="col-lg-6 well" id="billing_rates_panel"></div>
    </section>
    <section class="row">
      <div class="col-lg-12 well" id="repository_panel"></div>
    </section>
  """)

  regions:
    billingRatesPanel: "#billing_rates_panel"
    repositoryPanel: "#repository_panel"


  initialize: ->

    #Set up sub-views
    @billingRatesPanelView = new BillingRatesPanelView()
    @repositoryPanelView = new RepositoryPanelView()


  render: ->

    @$el.html(@template())

    # subviews
    @.billingRatesPanel.show(@billingRatesPanelView)
    @.repositoryPanel.show(@repositoryPanelView)
