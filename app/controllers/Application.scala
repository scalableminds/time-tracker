/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package controllers

import javax.inject.Inject

import play.api._
import play.api.i18n.MessagesApi
import play.api.mvc._
import views.html
import play.api.routing.JavaScriptReverseRouter

class Application @Inject()(
  config: Configuration,
  val messagesApi: MessagesApi) extends Controller {

  val hostUrl = config.getString("host.url").get

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

  def terms = UserAwareAction {
    implicit request =>
      Ok(html.terms())
  }

  def javascriptRoutes = Action { implicit request =>
    Ok(
      JavaScriptReverseRouter("jsRoutes")(
        // fill in stuff which should be able to be called from js
        controllers.routes.javascript.TimeEntryController.showTimesForInterval,
        controllers.routes.javascript.TimeEntryController.showTimeForUser
      )).as("text/javascript")
  }

}