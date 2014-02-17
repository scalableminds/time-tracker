### define
underscore : _
backbone : backbone
backbone.marionette : Marionette
views/admin/available_repositories_item : AvailableRepositoriesItem
models/admin/active_repositories_collection : ActiveRepositoriesCollection
models/log_time_model : LogTimeModel
datepicker : Datepicker
###

class LogTimeView extends Backbone.Marionette.CompositeView

  className : "log_time"
  title : "Log Time"
  template : _.template("""
    <div class="alert fade">
      <button type="button" class="close" data-dismiss="alert">×</button>
    </div>
    <div class="container">
      <form action="" method="POST" role="form">
        <h3>
          Log time for issue #
          <input id="issueNumber" class="form-control" type="text" value="<%= issueNumber %>" name="issueNumber" required="" pattern="^\d+$" style="width: 64px; display: inline; margin-left: 5px; font-size: 24px; padding: 0; text-align: center; ">
        </h3>
        <div class="form-group">
          <label class="control-label" for="repository">Repository</label>
          <div style="width: 100%">
            <select name="repository" class="form-control">
            </select>
          </div>

          <label class="control-label" for="duration">Duration</label>
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-clock-o"></i></span>
            <input id="duration" class="form-control" type="text" name="duration" autofocus="" required="" pattern="^\s*\-?\s*(?:(\d+)\s*d)?\s*(?:(\d+)\s*h)?\s*(?:(\d+)\s*m)?\s*$">
          </div>

          <label class="control-label" for="duration">Comment</label>
          <div class="input-group">
            <span class="input-group-addon"><i class="fa fa-comment-o"></i></span>
            <input id="comment" name="comment" class="form-control" type="text">
          </div>

          <label class="control-label" for="date">Date</label>
          <div class="input-group" >
            <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
            <input class="form-control" type="text" name="date" pattern="^\d{2}\.\d{2}\.\d{4}">
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
    "click .alert .close" : "closeAlert"
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
    @listenTo(@, "render", @afterRender)

  afterRender : =>

    @ui.inputDate
      .datepicker({format : "dd.mm.yyyy"})
      .datepicker("setValue", @model.get("timestamp").toDate())
      .datepicker("update")
      .on "changeDate", (evt) =>
        @model.set("timestamp", evt.date.valueOf())

#    @ui.labelAlert.alert()


  closeAlert : ->

    @ui.labelAlert.parent().removeClass("in")


  showDatePicker : ->

    @ui.inputDate.datepicker().show()


  submitTimeLog : (evt) ->

    evt.preventDefault()
    console.log @ui.inputDate.datepicker().getDate()

    unless @ui.form[0].checkValidity()
      showAlert("Your specified time couldn't be recognized. Use something like: 2h 10m", "failure")
      return


    model.save(
      repository : @ui.repository.find("option :selected").text()
      issueNumber : @ui.issueNumber.val()
      comment : @ui.inputComment.val()
      duration : @ui.inputDuration.val()
    ).done
    ->
      console.log "success"
    ->
      console.log  "ups"

