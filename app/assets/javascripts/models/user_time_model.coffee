### define
backbone : backbone
moment : moment
Utils : Utils
###

class UserTimeModel extends Backbone.Model

  urlRoot : ->

    dateUrl = Utils.dateToUrl(@get("date"))
    return "/user/times/#{dateUrl}"


  initialize : (options) ->

    @set("date", options.date)
    @listenTo(@, "sync", @afterSync)


  afterSync : ->

    @set("projects", new Backbone.Collection(_.flatten(_.toArray(@get("projects")))))


  getMonthlyTotalHours : ->

      return @get("projects").reduce(
        (sumTotal, project) ->
          return sumTotal + project.get("duration")
      , 0)


  getDailyTotalHours : (data) ->

    Utils.range(1, @get("date").daysInMonth()).map(
      (day) =>
        momentDay = moment(@get("date")).add("days", day - 1)
        @get("projects").reduce(
          (sumTotal, project) ->
            if moment(project.get("timestamp")).isSame(momentDay, "day")
              return sumTotal + project.get("duration")
            else
              return sumTotal
        , 0)
    )