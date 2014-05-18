### define
underscore : _
backbone.marionette: Marionette
###

class ActiveRepositoriesItemView extends Backbone.Marionette.ItemView

  tagName: "tr"
  template: _.template("""
    <td>
      <%= name %>
    </td>
    <td>
      <% admins.forEach(function(admin){ %>
        <span><%= admin.fullName %></span>
      <% }) %>
    </td>
    <td>
      <a id="scan" href="/api/repos/<%= id %>/scan"><i class="fa fa-refresh"></i> scan</a>
      <a id="remove" href="#"><i class="fa fa-trash-o"></i> remove</a>
    </td>
  """)

  events:
    "click a#remove": "removeItem"
    "click a#scan" : "scan"

  ui :
    "spinner" : ".fa-refresh"

  removeItem: ->

    @model.destroy()


  scan : (evt) ->

    evt.preventDefault()

    $.get(evt.target.href).done(=>
      @ui.spinner.removeClass("fa-spin")
    )

    @ui.spinner.addClass("fa-spin")
