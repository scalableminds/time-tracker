### define
jquery : $
app : app
###

app.addInitializer( ->

  $navbar = $("#main-nav")
  $navbar.on("click", "a", (evt)->

    $navbar.find(".active").removeClass("active")
    $(evt.currentTarget).closest("li").addClass("active")

    return

  )
)