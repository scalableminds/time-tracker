$ = require("jquery")
_ = require("underscore")
Marionette = require("marionette")
moment = require("moment")
app = require("app")

class MonthPickerView extends Marionette.ItemView

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


  monthPrevious : (evt) ->

    evt.preventDefault()
    date = @model.get("date").subtract("months", 1)
    @changeDate(date)
    return

  monthNext : (evt) ->

    evt.preventDefault()
    date = @model.get("date").add("months", 1)
    @changeDate(date)
    return


  changeDate : (date) ->

    url = "#{@model.get("urlRoot")}/#{date.year()}-#{date.month() + 1}"
    app.router.navigate(url, trigger : true)
    return


  monthReset : ->

    @changeDate(moment())
    return

module.exports = MonthPickerView

