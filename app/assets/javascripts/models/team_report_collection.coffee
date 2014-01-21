### define
backbone : Backbone
utils: Utils
###

class TeamReportCollection extends Backbone.Model

  constructor: (currentDate) ->

    super(
      currentDate: currentDate
      endOfMonth: currentDate.endOf("month").date()
      rows: new Backbone.Collection()
    )

    jsRoutes.controllers.TimeEntryController.showTimesForInterval(@get("currentDate").year(), @get("currentDate").month()+1).ajax().then (data) =>


      # Iterate of every user...
      _.each(data, (user) =>

        # and group his issue by his repositories (aka projects)
        timeEntries = _.groupBy(user.times, (timeEntry) -> timeEntry.issue.project)

        # Finally add the days of the month to every project...
        timeEntries = _.transform(timeEntries,
          (result, project, key) =>
            result[key] = _.range(0, @get("endOfMonth")).map(
              (day) -> return Utils.sum(
                project.filter(
                  (project) -> return moment(project.timestamp).date() == day
                ).map(
                  (projectFilterdByDay) -> return projectFilterdByDay.duration
                )
              )
            )
          )

        # Sum up the total amount of hours per day for every user
        dailySum = _.range(0, @get("endOfMonth")).map((i) -> return Utils.sum(_.values(timeEntries), i))
        totalSum = Utils.sum(dailySum)

        #Add that shit to the collection as a table 'header' for every user
        @get("rows").add(
          row:
            [user.name, totalSum].concat(dailySum)
          )

        _.each(timeEntries, (timeEntry, key) =>
          projectSum = Utils.sum(timeEntry)
          @get("rows").add(
            row: [key, projectSum].concat(timeEntry)
          )
        )
      )



