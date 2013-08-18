package controllers

import scala.None
import models.User

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 18.08.13
 * Time: 16:43
 */
object UserController extends Controller with securesocial.core.SecureSocial {
  val DefaultAccessRole = None

  def showSettings() = SecuredAction {
    implicit request =>
      Ok(views.html.user.settings(request.user.asInstanceOf[User]))
  }
}
