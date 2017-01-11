InfoPanelView = require("./info_panel_view")
RepositoryPanelView = require("./repository_panel_view")
Marionette = require("marionette")

class AdminPanelView extends Marionette.Layout

  className : "admin"
  template: _.template("""
    <section class="row">
      <div class="col-lg-12" id="repository-panel"></div>
    </section>
  """)

  regions:
    billingRatesPanel: "#billing-rates_panel"
    repositoryPanel: "#repository-panel"
    infoPanel: "#info-panel"

  initialize: ->

    #Set up sub-views
    #@billingRatesPanelView = new BillingRatesPanelView()
    #@infoPanelView = new InfoPanelView()
    @repositoryPanelView = new RepositoryPanelView()


  onRender: ->

    # subviews
    #@billingRatesPanel.show(@billingRatesPanelView)
    #@infoPanel.show(@infoPanelView)
    @repositoryPanel.show(@repositoryPanelView)


module.exports = AdminPanelView