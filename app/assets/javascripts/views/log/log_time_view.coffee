### define
underscore : _
backbone : backbone
backbone.marionette : Marionette
views/admin/available_repositories_item_view : AvailableRepositoriesItem
models/admin/active_repositories_collection : ActiveRepositoriesCollection
models/log/log_time_model : LogTimeModel
datepicker : Datepicker
###

class LogTimeView extends Backbone.Marionette.CompositeView

  className : "log-time"
  title : "Log Time"
  template : _.template("""
    <div class="container">
      <div class="alert fade">
        <button type="button" class="close" data-dismiss="alert">×</button>
      </div>
      <form action="" method="POST" role="form">
        <h3>
          Log time for issue #
          <input id="issueNumber" class="form-control" type="text" value="<%= issueNumber %>" name="issueNumber" required="" pattern="^\\d+$">
        </h3>
        <div class="form-group">
          <label class="control-label" for="repository">Repository</label>
          <div>
            <select name="repository" class="form-control">
            </select>
          </div>

          <label class="control-label" for="duration">Duration</label>
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-clock-o"></i></span>
            <input id="duration" class="form-control" type="text" name="duration" autofocus="" required="" pattern="^\\s*\\-?\\s*(?:(\\d+)\\s*d)?\\s*(?:(\\d+)\\s*h)?\\s*(?:(\\d+)\\s*m)?\\s*$">
          </div>

          <label class="control-label" for="comment">Comment</label>
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-comment-o"></i></span>
            <input id="comment" name="comment" class="form-control" type="text">
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

  events :
    "click .close" : "closeAlert"
    "click input[type=submit]" : "submitTimeLog"
    "click @ui.inputDate" : "showDatePicker"


  ui :
    labelAlert : ".alert"
    inputDate : "input[name=date]"
    inputComment : "input[name=comment]"
    inputDuration : "input[name=duration]"
    issueNumber : "#issueNumber"
    repository : "select"
    form : "form"


  initialize : ->

    @model = new LogTimeModel()
    @collection = new ActiveRepositoriesCollection()
    @collection.fetch()
    @listenTo(@, "render", @afterRender)


  afterRender : =>

    @ui.inputDate
      .datepicker({format : "yyyy-mm-dd"})
      .datepicker("setValue", @model.get("dateTime").toDate())
      .on "changeDate", (evt) =>
        @ui.inputDate.datepicker("hide")


  showDatePicker : ->

    @ui.inputDate.datepicker().show()


  submitTimeLog : (evt) ->

    evt.preventDefault()

    unless @ui.form[0].checkValidity()
      @showAlert("Your specified time couldn't be recognized. Use something like: 2h 10m", "danger")
      return


    @model.save(
      repository : @ui.repository.val()
      issueNumber : @ui.issueNumber.val()
      comment : @ui.inputComment.val()
      duration : @ui.inputDuration.val()
      dateTime : moment.utc(@ui.inputDate.val()).toISOString()
    ).then(
      =>
        @showAlert("You time entry was successfully logged.", "success")
      =>
        @showAlert("Ups. We couldn't save your time log.", "danger")
    )

  showAlert : (msg, className = danger) ->

    # clear existing styles
    @ui.labelAlert
      .removeClass("alert-success")
      .removeClass("alert-danger")
      .text(msg)

      @ui.labelAlert.addClass("alert-#{className} in")

