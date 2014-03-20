### define
backbone : Backbone
moment : moment
utils: Utils
###

class TeamReportModel extends Backbone.Model

  defaults :
    currentDate : null
    endOfMonth : null
    rows : new Backbone.Collection()
    api : null
    monthlyTotalHours : 0
    dailyTotalHours : 0

  initialize : (options) ->

    date = moment(options?.date) || moment()
    @set(
      currentDate : date
      endOfMonth : date.endOf("month").date()
    )


  fetch : ->

    dateUrl = Utils.dateToUrl(@get("currentDate"))
    @urlRoot = "/times/#{dateUrl}"
    super()


  parse : (response) ->

    # Make sure we save the server data under a meaningful attribute
    return {
      api : response
      monthlyTotalHours: @getMonthlyTotalHours(response)
      dailyTotalHours: @getDailyTotalHours(response)
    }


  getMonthlyTotalHours : (data) ->

    _.reduce(data, (sumTotal, user) ->
      return sumTotal + _.reduce(user.times, (sum, time) ->
        return sum + time.duration
      , 0)
    , 0)


  getDailyTotalHours : (data) ->

    #TODO
    _.range(1, @get("endOfMonth")).map(
      -> return 0
    )



