### define
backbone : Backbone
###

class TeamReportModel extends Backbone.Model


  constructor: (currentDate) ->

    super(
      currentDate: currentDate
      endOfMonth: currentDate.endOf("month").date()
      api: null
      rows: new Backbone.Collection()
    )

    @urlRoot = "/times/#{currentDate.year()}/#{currentDate.month() + 1}"


  parse: (response) ->

    # Make sure we save the server data under a meaningful attribute
    return {
      api : response
    }

  getTotalHours: ->








