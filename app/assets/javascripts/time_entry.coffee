### define 
jquery : $
bootstrap : bootstrap
###

->

  $alert = $(".alert")
  $alert.alert()
  $(".alert .close").click ->
    $(this).parent().removeClass("in")

  DATE_FORMAT = "dd.mm.yyyy"

  currentDate = moment()

  datepicker = $("[data-datepicker] input").datepicker(
    format : DATE_FORMAT
  )

  datepicker.on "changeDate", (event) ->
    currentDate = moment(event.date.valueOf())

  datepicker.datepicker("setValue", currentDate.toDate())
  datepicker.datepicker('update')


  $("input[type=submit]").on "click", (evt) ->

    evt.preventDefault()

    $form = $("form")


    unless $form[0].checkValidity()
      showAlert("Your specified time couldn't be recognized. Use something like: 2h 10m", "failure")
      return

    duration = $("#duration").val()
    timestamp = 1000 * currentDate.unix()
    comment = $("#comment").val()

    $.ajax(

      url: $form.attr("action")
      method: $form.attr("method")
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      data: JSON.stringify {duration, timestamp, comment}
    )
    .done( -> 
      
      setTimeout(
        ->
          if isUserComingFromGithub()
            # hacky hack hack
            open(location, '_self').close();
          else
            window.history.back()
        1000
      )
      showAlert("Yeah! Your time got logged.", "success")
      # dismissAlert()
    )
    .fail (jqXHR, textStatus, error ) ->
      
      console.error("There was an error submitting the entry:", error)
      showAlert("Ups! Something went wrong.", "failure")
      # dismissAlert()


  isUserComingFromGithub = ->

    # unfortunately, the referrer never seems to be set when the user comes from github
    # so, we just check if timer.scm.io is in the referrer
    # don't close on localhost (for development)
    return document.referrer.indexOf("timer.scm.io") == -1 and document.location.toString().indexOf("localhost") == -1


  showAlert = (msg, state) ->

    # clear existing styles
    $alert.removeClass("alert-success")
    $alert.removeClass("alert-danger")
    
    $alert.text(msg)

    if state == "success"
      $alert.addClass("alert-success in")
    else
      $alert.addClass("alert-danger in")


  dismissAlert = ->

    window.setTimeout (->
      $alert.removeClass("alert-danger")
      $alert.removeClass("alert-success")
      $alert.hide()
    ), 5000