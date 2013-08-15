### define
jquery : $
underscore : _
backbone : Backbone
moment : moment
###

class MonthPicker extends Backbone.View

  className : "month-picker"

  template : _.template("""
    <div class="btn-group">
        <button class="btn btn-default month_prev"><i class=" icon-chevron-left"></i></button>
        <button class="btn btn-default month_title" disabled><%= monthTitle %></button> 
        <button class="btn btn-default month_next"><i class=" icon-chevron-right"></i></button>
    </div>
  """)

  events :

    "click .month_prev" : "monthPrev"
    "click .month_next" : "monthNext"


  initialize : ->

    @model ?= moment()


  monthPrev : ->

    @model = @model.subtract("months", 1)
    @trigger("prev", @model)
    @trigger("change", @model)
    @updateMonthTitle()
    return

  monthNext : ->

    @model = @model.add("months", 1)
    @trigger("next", @model)
    @trigger("change", @model)
    @updateMonthTitle()
    return


  updateMonthTitle : ->

    @$el.find(".month_title").text(moment(@model).format("MMMM YYYY"))


  render : ->

    @$el.append(@template( monthTitle : moment(@model).format("MMMM YYYY") ))