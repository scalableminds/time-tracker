### define
underscore : _
backbone.marionette : Marionette
views/components/selection_view : SelectionView
models/admin/active_repositories_collection : ActiveRepositoriesCollection
###

class UserSettingsView extends Backbone.Marionette.Layout

  className : "col-sm-6 col-sm-offset-3"

  regions:
    defaultRepositorySelector: "#default_repository_selector"



  template : _.template("""
    <section>
      <h3>Settings</h3>
      <form role="form">
        <div class="form-group">
          <label>Default repository</label>
          <div id="default_repository_selector"></div>
        </div>
        <div class="checkbox">
          <label>
            <input type="checkbox" name="closeAfterGithub"> Close page after logging when coming from Github.
          </label>
        </div>
        <button class="btn btn-primary">Save</button>
      </form>
    </section>
    <section>
      <h3>Access-Key</h3>
      <div class="form-group">
        <input class="form-control" id="access-key-input" value="" disabled>
      </div>
      <a id="generate-acccess-key-button" href="#" class="btn btn-default">
        <i class="fa fa-camera-retro"></i> Generate new Access-Key
      </a>
    </section>

    <section>
      <h3>Change permissions</h3>
      <a href="reauthorize" class="btn btn-default">Grant public/private access</a>
    </section>
  """)

  events :
    "submit form" : "handleSave"
    "click @ui.generateAccessKeyButton" : "generateAccessKey"

  ui :
    closeAfterGithub : "[name=closeAfterGithub]"
    accessKeyInput : "#access-key-input"
    generateAccessKeyButton : "#generate-acccess-key-button"


  initialize : ->

    @defaultRepositorySelectorView = new SelectionView(
      collection : new ActiveRepositoriesCollection()
      itemViewOptions :
        valueFunc : -> return @model.get("name")
      name : "defaultRepository"
    )

    @listenTo(@, "render", @afterRender)
    @listenTo(@model, "sync", @render)

    @listenTo(@defaultRepositorySelectorView, "render", ->
      defaultRepository = @model.get("defaultRepository")
      if defaultRepository
        @defaultRepositorySelectorView.setValue(defaultRepository)
    )


  afterRender : ->

    @defaultRepositorySelector.show(@defaultRepositorySelectorView)
    @ui.closeAfterGithub.prop("checked", @model.get("closeAfterGithub"))
    @updateAccessKey()


  handleSave : (event) ->

    event.preventDefault()
    @model.save(
      defaultRepository : @defaultRepositorySelectorView.getValue()
      closeAfterGithub : @ui.closeAfterGithub.prop("checked")
    )


  generateAccessKey : (event) ->

    event.preventDefault()
    $.ajax(
      method : "POST"
      url : "/api/user/accesskey"
      datatype : "json"
    ).done( =>
      @updateAccessKey()
    )


  updateAccessKey : ->

    $.ajax(
      url : "/api/user"
      datatype : "json"
    ).done( (userObj) =>
      @ui.accessKeyInput.val(userObj.accessKey)
      return
    )
