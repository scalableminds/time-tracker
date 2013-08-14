define ["alert"], ->

  $alert = $(".alert")
  $alert.alert()

  $("input[type=submit]").on "click", (evt) ->

    evt.preventDefault()

    $form = $("form")

    $.ajax(

      url: $form.attr("action")
      method: $form.attr("method")
      data: $form.serialize()
    )
    .done( -> 

      $alert.addClass("alert-success")
      $alert.text("Yeah! Your time got logged.")
      $alert.show()
      dismissAlert()
    )
    .fail (jqXHR, textStatus, error ) ->

      $alert.addClass("alert-error")
      $alert.text("Ups! Something went wrong.")
      $alert.show()
      console.error("There was an error submitting the entry: #{error}")
      dismissAlert()


  dismissAlert = ->

    window.setTimeout (->
      $alert.removeClass("alert-error")
      $alert.removeClass("alert-success")
      $alert.alert("close")
    ), 2000