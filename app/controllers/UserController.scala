package controllers

import scala.None
import models.{UserDAO, User}
import play.api.libs.concurrent.Execution.Implicits._
import models.services.UserCache
import play.api.libs.json.Writes

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 18.08.13
 * Time: 16:43
 */
object UserController extends Controller with securesocial.core.SecureSocial {
  val DefaultAccessRole = None

  def list = SecuredAction.async {
    implicit request =>
      for {
        users <- UserDAO.findAll
      } yield {
        Ok(Writes.list(User.publicUserWrites).writes(users))
      }
  }

  def read(id: String) = SecuredAction.async {
    implicit request =>
      for {
        user <- UserDAO.findOneByGID(id)
      } yield {
        Ok(User.publicUserWrites.writes(user))
      }
  }

  def showSettings() = SecuredAction {
    implicit request =>
      Ok(views.html.user.settings(request.user.asInstanceOf[User]))
  }

  def createAccessKey() = SecuredAction.async {
    implicit request =>
      val a = User.generateAccessKey
      val user = request.user.asInstanceOf[User]
      for {
        _ <- UserDAO.setAccessKey(user, a)
      } yield {
        UserCache.removeUserFromCache(user.identityId)
        JsonOk("A new access key was created.")
      }
  }
}
