### define
backbone : backbone
moment : moment
Utils : Utils
./team_time_model : TeamTimeModel
###

class TeamTimeCollection extends Backbone.Collection

  model : TeamTimeModel

  initialize : (options) ->

    @date = moment(options?.date) || moment()


  url : ->

    dateUrl = Utils.dateToUrl(@date)
    return "/times/#{dateUrl}"


  getIssuesByUser : (userName) ->

    user = @findWhere(name : userName)

    if user
      return user

    else
      throw new Error("There is no user called '#{userName}'")


  getMonthlyTotalHours : ->

    return @reduce(
      (sumTotal, user) ->
        return sumTotal + user.get("times").reduce( (sum, time) ->
          return sum + time.get("duration")
        , 0)
    , 0)


  getDailyTotalHours : (data) ->

    #TODO @normanrz
    _.range(1, Utils.endOfMonth(@date)).map(
      (day) -> return 0
    )