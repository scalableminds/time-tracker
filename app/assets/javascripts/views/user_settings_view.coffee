### define
underscore : _
backbone.marionette : Marionette
###

class UserSettingsView extends Backbone.Marionette.ItemView

  template : _.template("""
    <h3>@user.profile.fullName</h3>
    <div class="form-group">
      <label class="control-label" for="">Access-Key</label>
      <div class="input-group">
        <input class="form-control" value="@user.accessKey.getOrElse("n/a")" disabled>
        <span class="input-group-btn">
          <a id="generateKey" data-url="@controllers.routes.UserController.createAccessKey()" href="#" class="btn btn-default">
            <i class="icon-camera-retro"></i> generate
          </a>
        </span>
      </div>
    </div>
  """)
