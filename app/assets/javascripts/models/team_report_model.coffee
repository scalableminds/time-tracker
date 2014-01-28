### define
backbone : Backbone
utils: Utils
###

class TeamReportModel extends Backbone.Model


  constructor : (currentDate) ->

    super(
      currentDate : currentDate
      endOfMonth : currentDate.endOf("month").date()
      rows : new Backbone.Collection()
      api : null
      monthlyTotalHours : 0
      dailyTotalHours : 0
    )

    @urlRoot = "/times/#{currentDate.year()}/#{currentDate.month() + 1}"


  parse : (response) ->

    # Make sure we save the server data under a meaningful attribute
    a = {
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



