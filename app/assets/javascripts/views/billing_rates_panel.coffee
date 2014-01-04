### define
jquery : $
underscore : _
backbone : Backbone
###

class BillingRatesPanel extends Backbone.View

  template: _.template("""
    <h1>Fuck yeah</h1>
  """)

  initialize: ->



  render: ->

    @$el.html(@template())
