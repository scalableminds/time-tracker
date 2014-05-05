### define
jquery : $
underscore : _
backbone.marionette: Marionette
moment : moment
app : app
###

class MonthPickerView extends Backbone.Marionette.ItemView

  className : "month-picker"

  template : _.template("""
    <div class="btn-group">
      <a href="#" class="btn btn-default month-prev">
        <i class="fa fa-chevron-left"></i>
      </a>
      <button class="btn btn-default month-title"><%= date.format("MMMM YYYY") %></button>
      <a href="#" class="btn btn-default month-next">
        <i class="fa fa-chevron-right"></i>
      </a>
    </div>
  """)

  events :
    "click .month-prev" : "monthPrevious"
    "click .month-next" : "monthNext"
    "click .month-title" : "monthReset"


  initialize : ->

     @listenTo(@, "render", @updateURL)


  monthPrevious : (evt) ->

    evt.preventDefault()
    @changeDate("subtract")
    return

  monthNext : (evt) ->

    evt.preventDefault()
    @changeDate("add")
    return


  changeDate : (operation) ->

    date = @model.get("date")
    @model.set("date", date[operation]("months", 1))
    @render()
    @model.fetch(reset : true)
    return


  monthReset : ->

    @model.set("date", moment())
    @render()
    return


  updateURL : ->

    url = "team/#{@model.get("date").year()}-#{@model.get("date").month() + 1}"
    app.router.navigate(
      url,
      replace : true
    )
