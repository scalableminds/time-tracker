Backbone = require("backbone")
Utils = require("utils")
moment = require("moment")

class UserTimeCollection extends Backbone.Collection

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
            if moment(user.get("dateTime")).isSame(momentDay, "day")
              return sumTotal + user.get("duration")
            else
              return sumTotal
        , 0)
    )

module.exports = UserTimeCollection