package controllers

import scala.None
import models.{UserDAO, User}
import play.api.libs.concurrent.Execution.Implicits._

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

  def createAccessKey() = SecuredAction {
    implicit request =>
      Async {
        val a = User.generateAccessKey
        for {
          _ <- UserDAO.setAccessKey(request.user.asInstanceOf[User], a)
        } yield {
          Ok(views.html.user.settings(request.user.asInstanceOf[User]))
        }
      }
  }
}
