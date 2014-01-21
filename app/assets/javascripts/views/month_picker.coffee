### define
jquery : $
underscore : _
backbone : Backbone
backbone.marionette: Marionette
moment : moment
###

class MonthPicker extends Backbone.Marionette.ItemView

  className : "month-picker"

  template : _.template("""
    <div class="btn-group">
      <a href="<%= prev.year %>-<%= prev.month %>" class="btn btn-default month-prev"><i class="fa  fa-chevron-left"></i></a>
      <button class="btn btn-default month-title"><%= monthTitle %></button>
      <a href="<%= next.year %>-<%= next.month %>" class="btn btn-default month-next"><i class="fa  fa-chevron-right"></i></a>
    </div>
  """)

  events :
    "click .month-prev" : "monthPrev"
    "click .month-next" : "monthNext"
    "click .month-title" : "monthReset"


  initialize : (date) ->

    @model = date || moment()


  monthPrev : ->

    @model = @model.subtract("months", 1)
    # @trigger("change", @model)
    # @updateMonthTitle()

    return


  monthNext : ->

    @model = @model.add("months", 1)
    # @trigger("next", @model)
    # @trigger("change", @model)
    # @updateMonthTitle()
    return


  monthReset : ->

    @model = moment()
    # @trigger("change", @model)
    # @updateMonthTitle()
    return


  updateMonthTitle : ->

    #@$el.find(".month-title").text(moment(@model).format("MMMM YYYY"))


  render : ->

    @$el.append(@template(
      monthTitle : moment(@model).format("MMMM YYYY")
      prev:
        year:
          moment(@model).subtract("months", 1).year()
        month:
          moment(@model).subtract("months", 1).month() + 1 # +1 because momentjs is zero initialized
      next:
        year:
          moment(@model).add("months", 1).year()
        month:
          moment(@model).add("months", 1).month() + 1
    ))

