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
    "click .month-prev" : "monthPrev"
    "click .month-next" : "monthNext"
    "click .month-title" : "monthReset"


  initialize : ->

     @listenTo(@, "render", @updateURL)


  monthPrev : (evt) ->

    evt.preventDefault()

    date = @model.get("currentDate")
    @model.set(date.subtract("months", 1))
    @render()
    return


  monthNext : (evt) ->

    evt.preventDefault()

    date = @model.get("currentDate")
    @model.set(date.add("months", 1))
    @render()
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
