### define
jquery : $
app : app
###

app.addInitializer( ->

  $navbar = $(".navbar-nav")
  $navbar.on "click", "a", (evt)->

    $navbar.find(".active").removeClass("active")
    $(evt.target).parent().addClass("active")

    return
)