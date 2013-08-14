define ["report"], (Report) ->

  class TeamTimeReport extends Report

    constructor : ->

      super()

      @setupUI()
      @loadData()


    loadData : ->

      $("#date").text("#{@currentDate.format('MMMM YYYY')}")
      @lastDay = @currentDate.endOf("month").date()

      year = @currentDate.format("YYYY")
      month = @currentDate.format("MM")

      $.ajax(
        methode: "GET"
        url: "http://localhost:9000/times/#{year}/#{month}"
      ).done( (data) =>
        @data = data

        @calcSums()

        $("#timetable thead").empty()
        $("#timetable tbody").empty()
        @printHeader()
        @printTimetable()


      ).fail( (jqXHR, textStatus, error) ->
        console.error("An error occured: #{error}")
      )


    printHeader : ->

      header = []
      header.push("User")
      header.push("&sum;")

      for project of @sumByProject
        header.push project

      $header = $("<tr>")
      header.forEach (h) ->
        $header.append("<th>#{h}</th>")

      $("#timetable thead").append($header)


    printTimetable : ->

      for user, timeEntries of @data

        $entry = $("<tr>")
        $entry.append("<td>#{user}</td>")
        $entry.append($("<td>", {class: "sumRight", text: "#{@sumByUser[user]}"}))

        for project of @sumByProject
          $entry.append("<td>#{@sumByUserProject[user+project]}</td>")

      $("#timetable tbody").append($entry)

      @printSumByProject()


    printSumByProject : ->

      $project = $("<tr>", {class: "warning"})
      $project.append("<td>&sum;</td>")
      $project.append($("<td>", {class: "sumRight", text: "#{@sumOverall}"}))

      for project, sum of @sumByProject
        $project.append("<td>#{sum}</td>")

      $("#timetable tbody").append($project)


    calcSums : ->

      sumByProject = {}
      sumByUser = {}
      sumByUserProject = {}
      sumOverall = 0

      for user, timeEntries of @data
        for entry in timeEntries

          issue = entry.issue 

          sumByProject[issue.project] = sumByProject[issue.project] + entry.duration || entry.duration
          
          uniqueID = user + issue.project
          sumByUserProject[uniqueID] = sumByUserProject[uniqueID] + entry.duration || entry.duration

          sumByUser[user] = sumByUser[user] + entry.duration || entry.duration

          sumOverall += entry.duration


      @sumByProject = sumByProject
      @sumByUserProject = sumByUserProject
      @sumByUser = sumByUser
      @sumOverall = sumOverall


