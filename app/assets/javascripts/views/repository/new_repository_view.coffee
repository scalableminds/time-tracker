### define
underscore : _
backbone.marionette : Marionette
libs/toast : Toast
###

class NewRepositoryView extends Backbone.Marionette.CompositeView

  className : "log-time row"
  template : _.template("""
    <div class="col-sm-6 col-sm-offset-3">
      <form action="" method="POST" role="form">
        <h3>
          Add new None-Github repository
        </h3>
        <div class="form-group">
          <label class="control-label" for="duration">Client</label>
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-user"></i></span>
            <input id="client" class="form-control reset" type="text" autofocus="" required="">
          </div>

          <label class="control-label" for="duration">Repository</label>
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-folder-o"></i></span>
            <input id="repository" class="form-control reset" type="text" autofocus="" required="">
          </div>

          <label class="control-label" for="comment">Admins</label>
          <div id="admin-selector">
            <select name="admin" class="form-control">
              <option>speedcom interceptor</option>
            </select>
          </div>

          <label class="control-label" for="comment">Users</label>
          <div id="user-selector">
            <select name="user" class="form-control">
              <option>speedcom interceptor</option>
            </select>
          </div>
        </div>
        <div class="form-group">
          <div class="col-sm-3 row">
            <button type="button" class="btn btn-block btn-default">Add</button>
          </div>
        </div>
        <select data-placeholder="Choose a country..." style="width:350px;" multiple class="chosen-select">
      </form>
    </div>
  """)

  events :
    "click .btn-default": "addNewRepo"

  ui :
    form     : "form"
    repoName : "#repository"
    client   : "#client"
    admins   : "#admin-selector select"
    users    : "#user-selector select"

  addNewRepo : ->

    unless @ui.form[0].checkValidity()
      Toast.error("You must type name of client and repository.")
      return

    @trigger("newRepo",
      name   : "#{@ui.client.val()}/#{@ui.repoName.val()}"
      admins : [ @ui.admins.val() ]
      users  : [ @ui.users.val() ]
    )


