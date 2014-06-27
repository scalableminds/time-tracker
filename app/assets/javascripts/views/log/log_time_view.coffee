### define
underscore : _
backbone : backbone
backbone.marionette : Marionette
app : app
views/admin/available_repositories_item_view : AvailableRepositoriesItem
models/admin/active_repositories_collection : ActiveRepositoriesCollection
datepicker : Datepicker
###

class LogTimeView extends Backbone.Marionette.CompositeView

  className : "log-time row"
  title : "Log Time"

  events :
    "click .close" : "closeAlert"
    "click input[type=submit]" : "submitTimeLog"
    "click @ui.inputDate" : "showDatePicker"


  initialize : ->

    @listenTo(this, "render", @afterRender)


  afterRender : ->

    @ui.inputDate
      .datepicker({format : "yyyy-mm-dd"})
      .datepicker("setValue", @model.get("dateTime").format("YYYY-MM-DD"))
      .on "changeDate", (evt) =>
        @ui.inputDate.datepicker("hide")


  showDatePicker : ->

    @ui.inputDate.datepicker().show()


  showAlert : (msg, className = danger) ->

    # clear existing styles
    @ui.labelAlert
      .removeClass("alert-success")
      .removeClass("alert-danger")
      .text(msg)

      @ui.labelAlert.addClass("alert-#{className} in")


  submitTimeLog : (evt) ->

    evt.preventDefault()

    unless @ui.form[0].checkValidity()
      @showAlert("Your specified time couldn't be recognized. Use something like: 2h 10m", "danger")
      return


    @save().then(
      =>
        if /\?.*referer=github/.test(window.location.href) and app.settings.get("closeAfterGithub")
          window.close()
        else
          @showAlert("You time entry was successfully logged.", "success")
    =>
        @showAlert("Ups. We couldn't save your time log.", "danger")
    )
