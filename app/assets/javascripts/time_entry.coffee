### define 
jquery : $
bootstrap : bootstrap
###

->

  $alert = $(".alert")
  $alert.alert()
  $(".close").click ->
    $(this).parent().removeClass 'in'

  dateFormat = "DD.MM.YYYY"
  currentDate = moment()
  $dp = $('.datepicker').datepicker()
  $dp.on 'changeDate', (ev) ->
    console.log "timestamp", ev.date.valueOf()
    currentDate = moment ev.date.valueOf()
    $(this).find("input").attr "value", currentDate.format(dateFormat)

  $dp.datepicker("setValue", currentDate.format(dateFormat))
  $dp.find("input").attr "value", currentDate.format(dateFormat)


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