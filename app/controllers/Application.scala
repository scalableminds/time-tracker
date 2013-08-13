package controllers

import play.api._
import play.api.mvc._
import securesocial.core.java.SecureSocial.SecuredAction
import securesocial.core.SecureSocial
import views.html

object Application extends Controller with SecureSocial {

  def index = Action {
    Ok(views.html.index("Your new application is ready."))
  }

  def home = SecuredAction {
    implicit request =>
      Ok(html.home())
  }

}