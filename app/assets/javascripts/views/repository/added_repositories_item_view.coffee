### define
underscore : _
backbone.marionette: Marionette
libs/toast : Toast
###

class AddedRepositoriesItemView extends Backbone.Marionette.ItemView

  tagName : "tr"
  template : _.template("""
    <td>
      <%= name %>
    </td>
    <td>
      <% admins.forEach(function(admin){ %>
        <span><%= admin %></span>
      <% }) %>
    </td>
    <td>
      <% users.forEach(function(user){ %>
        <span><%= user %></span>
      <% }) %>
    </td>
    <td>
      <a id="edit" href="/api/repos/<%= id %>/edit"><i class="fa fa-edit"></i> edit</a>
      <a id="remove" href="#"><i class="fa fa-trash-o"></i> remove</a>
    </td>
  """)

  events :
    "click a#remove" : "removeItem"
    "click @ui.edit" : "edit"

  ui :
    "edit" : "a#edit"

  onRender : ->

    @ui.edit.tooltip(title : "Gather issue titles and add log links if desired")


  removeItem : ->

    @model.destroy()


  edit : (evt) ->

    evt.preventDefault()

    $.get(evt.target.href).then(
      (res) => Toast.message(res.messages)
      (res) => Toast.message(res.responseJSON.messages)
    )
