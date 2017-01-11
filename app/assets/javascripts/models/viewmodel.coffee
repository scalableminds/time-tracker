Backbone = require("backbone")
UsersCollection = require("models/users_collection")
moment = require("moment")

class ViewModel extends Backbone.Model

  initialize : (options = {}) ->

    if options.date
      @set("date", moment(options.date, "YYYY-MM").startOf("month"))

    @dataSource = new @dataSourceClass()
    @usersCollection = new UsersCollection()


  fetch : =>

    @dataSource.date = @get("date")
    userPromise = @usersCollection.fetch()
    dataPromise = @dataSource.fetch()

    return $.when(userPromise, dataPromise).done(
      =>
        @set {
          monthlyTotalHours: @dataSource.getMonthlyTotalHours()
          dailyTotalHours: @dataSource.getDailyTotalHours()
        }
        @transformData()
        @trigger("sync", @)
    )

module.exports = ViewModel