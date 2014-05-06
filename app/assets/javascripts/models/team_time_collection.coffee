### define
backbone : backbone
moment : moment
Utils : Utils
###

class TeamTimeCollection extends Backbone.Collection

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
        return sumTotal + user.get("duration")
    , 0)


  getDailyTotalHours : (data) ->

    Utils.range(1, @date.daysInMonth()).map(
      (day) =>
        momentDay = moment(@date).add("days", day - 1)
        @reduce(
          (sumTotal, user) ->
            if moment(user.get("timestamp")).isSame(momentDay, "day")
              return sumTotal + user.get("duration")
            else
              return sumTotal
        , 0)
    )