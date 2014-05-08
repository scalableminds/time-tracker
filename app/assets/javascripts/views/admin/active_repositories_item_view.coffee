### define
underscore : _
backbone.marionette: Marionette
###

class ActiveRepositoriesItemView extends Backbone.Marionette.ItemView

  tagName: "tr"
  template: _.template("""
    <td>
      <%= fullName %>
    </td>
    <td>
      someone
    </td>
    <td>
      <a id="scan" href="/admin/repositories/<%= fullName %>/scan"><i class="glyphicon glyphicon-refresh"></i> scan</a>
      <a id="remove" href="#"><i class="glyphicon glyphicon-trash"></i> remove</a>
    </td>
  """)

  events:
    "click a#remove": "removeItem"


  removeItem: ->

    @model.destroy()