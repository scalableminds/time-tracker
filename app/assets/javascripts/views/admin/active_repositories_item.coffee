### define
underscore : _
backbone.marionette: Marionette
###

class ActiveRepositoriesItem extends Backbone.Marionette.ItemView

  tagName: "tr"
  template: _.template("""
    <td>
      <%= id %>
    </td>
    <td>
      <%= repository %>
    </td>
    <td>
      <%= accessToken %>
    </td>
    <td>
      <%= adminId %>
    </td>
    <td>
      <a id="scan" href="/admin/repositories/<%= repository %>/scan"><i class="glyphicon glyphicon-refresh"></i> scan</a>
      <a id="remove" href="/admin/repositories/<%= repository %>"><i class="glyphicon glyphicon-trash"></i> remove</a>
    </td>
  """)

  events:
    "click a#remove": "removeItem"

  removeItem: ->

    @model.destroy()