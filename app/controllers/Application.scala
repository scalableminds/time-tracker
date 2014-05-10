/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package controllers

import play.api._
import play.api.mvc._
import views.html

object Application extends Controller {
  val hostUrl = Play.current.configuration.getString("host.url").get

  def index = UserAwareAction { implicit request =>
    if (request.userOpt.isDefined)
      Redirect(controllers.routes.Application.home)
    else
      Ok(views.html.index("Your new application is ready."))
  }

  def home = Authenticated {
    implicit request =>
      Ok(html.home())
  }

  def team(any: String) = Authenticated {
    implicit request =>
      Ok(html.team())
  }

  def faq = UserAwareAction {
    implicit request =>
      Ok(html.faq())
  }

  def javascriptRoutes = Action { implicit request =>
    Ok(
      Routes.javascriptRouter("jsRoutes")(
        // fill in stuff which should be able to be called from js
        controllers.routes.javascript.TimeEntryController.showTimesForInterval,
        controllers.routes.javascript.TimeEntryController.showTimeForUser
      )).as("text/javascript")
  }

}