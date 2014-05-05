### define
backbone : backbone
moment : moment
Utils : Utils
./team_time_model : TeamTimeModel
###

class TeamTimeCollection extends Backbone.Collection

  model : TeamTimeModel

  initialize : (options) ->

    @date = options.date

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
        return sumTotal + user.get("times")
          .reduce( (sum, time) ->
            return sum + time.get("duration")
          , 0)
    , 0)


  getDailyTotalHours : (data) ->

    _.range(1, @date.daysInMonth()).map(
      (day) =>
        momentDay = moment(@date).add("days", day - 1)
        @reduce(
          (sumTotal, user) ->
            return sumTotal + user.get("times")
              .filter((time) ->
                moment(time.get("timestamp")).isSame(momentDay, "day")
              )
              .reduce(
                (sum, time) ->
                  return sum + time.get("duration")
              , 0)
        , 0)
    )