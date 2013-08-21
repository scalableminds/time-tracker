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


  $("input[type=submit]").on "click", (evt) ->

    evt.preventDefault()

    $form = $("form")

    duration = $("#duration").val()
    timestamp = 1000 * currentDate.unix()

    console.log {duration, timestamp}
    
    $.ajax(

      url: $form.attr("action")
      method: $form.attr("method")
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      data: JSON.stringify {duration, timestamp}
    )
    .done( -> 

      setTimeout(
        -> window.history.back()
        1000
      )
      $alert.text("Yeah! Your time got logged.")
      $alert.addClass("alert-success in")
      # dismissAlert()
    )
    .fail (jqXHR, textStatus, error ) ->

      $alert.addClass("alert-error in")
      $alert.text("Ups! Something went wrong.")

      console.error("There was an error submitting the entry:", error)
      # dismissAlert()

  dismissAlert = ->

    window.setTimeout (->
      $alert.removeClass("alert-error")
      $alert.removeClass("alert-success")
      $alert.hide()
    ), 5000