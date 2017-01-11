Marionette = require("marionette")
_ = require("underscore")

class BillingRatesItemView extends Marionette.ItemView

  tagName: "tr",
  template: _.template("""
    <td>
      <%= project %>
    </td>
    <td>
      <%= rate %>€
      <a href="#" class="pull-right" id="link_remove_item"><i class="glyphicon glyphicon-remove"></i></a>
    </td>
  """)

  events:
    "click #link_remove_item": "removeItem"


  removeItem: ->

    @model.destroy()

module.exports = BillingRatesItemView