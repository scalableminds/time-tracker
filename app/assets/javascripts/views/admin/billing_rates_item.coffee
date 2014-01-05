### define
underscore : _
backbone.marionette : Marionette
###

class BillingRatesItem extends Backbone.Marionette.ItemView

  tagName: "tr",
  template: _.template("""
    <td>
      <%= project %>
    </td>
    <td>
      <%= rate %>
      <a href="#" class="pull-right" id="link_remove_item"><span class="glyphicon glyphicon-remove"></a>
    </td>
  """)

  events:
    "click #link_remove_item": "removeItem"


  removeItem: ->

    @model.destroy()