### define 
jquery : $
bootstrap : bootstrap
###

->

  $alert = $(".alert")
  $alert.alert()
  $(".close").click ->
    $(this).parent().removeClass 'in'

  $("input[type=submit]").on "click", (evt) ->

    evt.preventDefault()

    $form = $("form")

    $.ajax(

      url: $form.attr("action")
      method: $form.attr("method")
      data: $form.serialize()
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