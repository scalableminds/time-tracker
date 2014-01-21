### define
backbone.marionette : Marionette
views/month_picker: MonthPickerView
###

class TimeReport extends Backbone.Marionette.Layout

  template: _.template("""
    <div class="row">
      <h2 class="col-lg-5 col-xs-12"><%= title %></h2>
      <div class="col-lg-7 col-xs-12 picker"></div>
    </div>
    <div class="report-table"></div>
  """)

  regions:
    monthPicker: ".picker"
    reportTable: ".report-table"


  constructor: (report, date) ->

    super()

    @currentReport = new report(date)
    @monthPickerView = new MonthPickerView(date)


  render: ->

    title = @currentReport.title
    @$el.html(@template({title: title}))

    @monthPicker.show(@monthPickerView)
    @reportTable.show(@currentReport)