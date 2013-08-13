define ["moment"], ->

  data = {
    "user" : "tmbo",
    "projects": {
      "brainflight": 
        [
          { 
              "issueNumber": 0,
              "time": 10
              "title": "BF-101 Build time tracker"
              "date": "2013-08-01T00:08:59.181Z"
          },
          {
              "issueNumber": 2,
              "time": 60
              "title": "BF-12 Work some more!"
              "date": "2013-08-12T00:08:59.181Z"
          }
        ]
      ,"oxalis": 
        [
          { 
              "issueNumber": 4,
              "time": 10
              "title": "OX-1 satisfy Moritz"
              "date": "2013-08-30T00:08:59.181Z"
          },
          {
              "issueNumber": 12,
              "time": 60
              "title": "OX-1000 sell Oxalis"
              "date": "2013-08-10T00:08:59.181Z"
          }
        ]
      }
  }

  class UserTimeReport

    constructor : ->

      #make sure we use the width
      $("#main-container").removeClass("container")

      @lastDay = moment().endOf("month").date()
      
      @calcSums()
      @printInfo()
      @printHeader()
      @printTimeTable()


    printInfo : ->

      #general info
      $("#user").text("#{data.user}")
      $("#timespan").text("| #{moment().startOf("month").format("D MMM YYYY")} - #{moment().endOf("month").format("D MMM YYYY")}")


    printHeader : ->

      header = []
      header.push("Key")
      header.push("Summary")
      header.push("&sum;")

      for day in [1..@lastDay]
        header.push(@padNumber(day))

      $header = $("<tr>")
      header.forEach (h) ->
        $header.append("<th>#{h}</th>")

      $("#timetable thead").append($header)


    printTimeTable : ->

      for project, issues of data.projects

        $project = $("<tr>", {class: "project"})
        $project.append("<td>")
        $project.append("<td>#{project}</td>")
        $project.append("<td>")
        for day in [1..@lastDay]
          $project.append("<td>")

        $("#timetable tbody").append($project)

        @printIssues(issues)

      @printSumByDay()


    printIssues : (issues) ->
      
      for issue in issues

        $issue = $("<tr>")
        $issue.append("<td>#{issue.issueNumber}</td>")
        $issue.append("<td>#{issue.title}</td>")
        $issue.append($("<td>", {class: "sumByIssue", text: "#{@sumByIssue[issue.issueNumber]}"}))
        
        for day in [1..@lastDay]
          if day == moment(issue.date).date()
            $issue.append($("<td>", {text: "#{[issue.time]}", class: "edit-time", "data-issueNumber": issue.issueNumber}))
          else
            $issue.append($("<td>", {class: "edit-time"}))

        $("#timetable tbody").append($issue)


    printSumByDay : ->

      #print sum by day
      $tbody = $("<tbody>")

      $issue = $("<tr>", {class: "warning"})
      $issue.append("<td></td>")
      $issue.append("<td>&sum;</td>")
      $issue.append("<td>#{@sumOverall}</td>")
      for day in [1..@lastDay]
        sum = @sumByDay[day] || String("")
        $issue.append("<td>#{sum}</td>")

      $("#timetable tbody").append($issue)

      @initPopup()


    calcSums : ->

      #calculate the sum of minutes worked on each issue
      sumByIssue = {}
      sumByDay = {}
      sumByProject = {}
      sumOverall = 0

      for project, issue of data.projects
        issue.forEach (issue)->
          sumByIssue[issue.issueNumber] = sumByIssue[issue.issueNumber] + issue.time || issue.time
          sumByProject[project] = sumByProject[project] + issue.time || issue.time

          day = moment(issue.date).date() #day of the month
          sumByDay[day] = sumByDay[day] + issue.time || issue.time 

          sumOverall += issue.time

      @sumByIssue = sumByIssue
      @sumByDay = sumByDay
      @sumByProject = sumByProject
      @sumOverall = sumOverall


    initPopup : ->

      #make time entries editable
      $popup = $("#popup")
      $popup.on "click", (evt) -> $popup.hide()
      $("body").on "click", (evt) -> $popup.hide()

      $(".edit-time").on "click", (evt) ->
        
        evt.stopPropagation()

        $el = $(evt.target)
        width= $el.width()
        value = $el.text()
        issueNumber = $el.data("issueNumber")

        $popup.toggle()


    #utilities
    padNumber : (number) ->

      String("0#{number}").slice(-2)
