### define
underscore : _
jquery : $
backbone : Backbone
moment : moment
models/users_collection : UsersCollection
###

class ViewModel extends Backbone.Model

  initialize : (options = {}) ->

    if options.date
      @set("date", moment(options.date).startOf("month"))

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