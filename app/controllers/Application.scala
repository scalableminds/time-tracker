package controllers

import play.api._
import play.api.mvc._
import securesocial.core.java.SecureSocial.SecuredAction
import securesocial.core.SecureSocial
import views.html

object Application extends Controller with SecureSocial {
  val hostUrl = Play.current.configuration.getString("host.url").get

  def index = UserAwareAction{ implicit request =>
    if(request.user.isDefined)
      Redirect(controllers.routes.Application.home)
    else
      Ok(views.html.index("Your new application is ready."))
  }

  def home = SecuredAction {
    implicit request =>
      Ok(html.home())
  }

  def team = SecuredAction {
    implicit request =>
      Ok(html.team())
  }

  def javascriptRoutes = Action { implicit request =>
    Ok(
      Routes.javascriptRouter("jsRoutes")(
        // fill in stuff which should be able to be called from js
        controllers.routes.javascript.TimeEntryController.showTimeForUser
      )).as("text/javascript")
  }

}