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
      <button class="btn btn-default month-title"><%= currentDate.format("MMMM YYYY") %></button>
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

    date = @model.get("currentDate")
    @model.set(date[operation]("months", 1))
    @render()
    app.vent.trigger("MonthPickerView:changed")
    return


  monthReset : ->

    @model.set("currentDate", moment())
    @render()
    return


  updateURL : ->

    url = "team/#{@model.get("currentDate").year()}-#{@model.get("currentDate").month() + 1}"
    app.router.navigate(
      url,
      replace : true
    )
