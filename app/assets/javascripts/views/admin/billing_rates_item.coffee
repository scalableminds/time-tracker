### define
jquery : $
underscore : _
backbone.marionette : Marionette
###

class BillingRatesItem extends Backbone.Marionette.ItemView

  tagName: "tr",
  template: _.template("""
    <td><%= project %></td>
    <td><%= rate %></td>
  """)
