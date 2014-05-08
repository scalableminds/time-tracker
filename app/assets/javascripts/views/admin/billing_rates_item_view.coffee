### define
underscore : _
backbone.marionette : Marionette
###

class BillingRatesItemView extends Backbone.Marionette.ItemView

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