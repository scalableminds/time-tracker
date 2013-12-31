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
	<button class="btn btn-default month-prev"><i class=" icon-chevron-left"></i></button>
	<button class="btn btn-default month-title"><%= monthTitle %></button>
	<button class="btn btn-default month-next"><i class=" icon-chevron-right"></i></button>
    </div>
  """)

  events :

    "click .month-prev" : "monthPrev"
    "click .month-next" : "monthNext"
    "click .month-title" : "monthReset"


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


  monthReset : ->

    @model = moment()
    @trigger("change", @model)
    @updateMonthTitle()
    return


  updateMonthTitle : ->

    @$el.find(".month-title").text(moment(@model).format("MMMM YYYY"))


  render : ->

    @$el.append(@template( monthTitle : moment(@model).format("MMMM YYYY") ))

