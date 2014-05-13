### define
underscore : _
backbone : backbone
backbone.marionette : Marionette
views/log/log_time_view : LogTimeView
models/log/repository_model : RepositoryModel
###

class LogTimeLocalView extends LogTimeView

  template : _.template("""
    <div class="col-sm-6 col-sm-offset-3">
      <div class="alert fade">
        <button type="button" class="close" data-dismiss="alert">×</button>
      </div>
      <form action="" method="POST" role="form">
        <h3>
          Log time for <span id="repo-name"></span> #<%= issueNumber %>
        </h3>
        <div class="form-group">
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

  ui :
    labelAlert : ".alert"
    inputDate : "input[name=date]"
    inputComment : "input[name=comment]"
    inputDuration : "input[name=duration]"
    form : "form"
    repoNameLabel : "#repo-name"


  initialize : ->

    super()

    @repositoryModel = new RepositoryModel(id : @model.get("id"))
    @repositoryModel.fetch().done( =>
      repoName = @repositoryModel.get("name")
      @ui.repoNameLabel.text(repoName)
    )

  save : ->

    @model.save(
      comment : @ui.inputComment.val()
      duration : @ui.inputDuration.val()
      dateTime : moment.utc(@ui.inputDate.val()).toISOString()
    , method : "POST"
    )