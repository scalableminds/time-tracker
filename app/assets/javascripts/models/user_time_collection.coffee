### define
backbone : backbone
moment : moment
Utils : Utils
###

class UserTimeCollection extends Backbone.Collection

  date : moment().startOf("month")

  url : ->

    dateUrl = Utils.dateToUrl(@date)
    return "/api/user/times/#{dateUrl}"


  getMonthlyTotalHours : ->

    return @reduce(
      (sumTotal, user) ->
        return sumTotal + user.get("duration")
    , 0)


  getDailyTotalHours : (data) ->

    return Utils.range(1, @date.daysInMonth()).map(
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
