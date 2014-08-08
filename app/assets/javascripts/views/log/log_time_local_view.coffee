### define
underscore : _
backbone.marionette : Marionette
views/log/log_time_view : LogTimeView
views/admin/available_repositories_item_view : AvailableRepositoriesItem
models/admin/active_repositories_collection : ActiveRepositoriesCollection
###

class LogTimeLocalView extends LogTimeView

  template : _.template("""
    <div class="col-sm-6 col-sm-offset-3">
      <form action="" method="POST" role="form">
        <h3>
          Log time for issue #
          <input id="issueNumber" class="form-control reset" type="text" value="<%= issueNumber %>" name="issueNumber" required="" pattern="^\\d+$">
        </h3>
        <div class="form-group">
          <label class="control-label" for="repository">Repository</label>
          <div id="repository-selector">
            <select name="repository" class="form-control">
            </select>
          </div>

          <label class="control-label" for="duration">Duration</label>
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-clock-o"></i></span>
            <input id="duration" class="form-control reset" type="text" name="duration" autofocus="" required="" pattern="^\\s*\\-?\\s*(?:(\\d+)\\s*d)?\\s*(?:(\\d+)\\s*h)?\\s*(?:(\\d+)\\s*m)?\\s*$">
          </div>

          <label class="control-label" for="comment">Comment</label>
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-comment-o"></i></span>
            <input id="comment" name="comment" class="form-control reset" type="text">
          </div>

          <label class="control-label" for="date">Date</label>
          <div class="input-group" >
            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
            <input class="form-control" type="text" name="date" pattern="^\\d{4}\\-\\d{2}\\-\\d{2}">
          </div>
        </div>
        <div class="form-group">
          <input type="submit" value="Log" class="btn btn-default">
        </div>
      </form>
    </div>
  """)

  itemView : AvailableRepositoriesItem
  itemViewContainer : "select"

  ui :
    inputDate : "input[name=date]"
    inputComment : "input[name=comment]"
    inputDuration : "input[name=duration]"
    issueNumber : "#issueNumber"
    repository : "#repository-selector select"
    form : "form"


  initialize : ->

    super()

    @collection = new ActiveRepositoriesCollection()
    @collection.fetch().done(@setDefaultRepository.bind(this))
    @listenTo(app.settings, "sync", @setDefaultRepository)


  setDefaultRepository : ->

    defaultRepository = app.settings.get("defaultRepository")
    if defaultRepository
      @ui.repository.val(defaultRepository)


  save: ->

    @model.save(
      repository : @ui.repository.val()
      issueNumber : @ui.issueNumber.val()
      comment : @ui.inputComment.val()
      duration : @ui.inputDuration.val()
      dateTime : moment.utc(@ui.inputDate.val()).toISOString()
      id : @ui.repository.find(":selected").prop("id")
    , method : "POST"
    )
