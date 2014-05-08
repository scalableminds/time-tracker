package controllers

import scala.None
import models.{UserDAO, User}
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.json.Writes
import models.auth.UserCache
import play.api.libs.json.Json

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 18.08.13
 * Time: 16:43
 */
object UserController extends Controller {
  val DefaultAccessRole = None

  def list = Authenticated.async {
    implicit request =>
      for {
        users <- UserDAO.findAll
      } yield {
        Ok(Writes.list(User.publicUserWrites).writes(users))
      }
  }

  def read(id: Int) = Authenticated.async {
    implicit request =>
      for {
        user <- UserDAO.findOneByUserId(id)
      } yield {
        Ok(User.publicUserWrites.writes(user))
      }
  }

  def showSettings() = Authenticated {
    implicit request =>
      Ok(views.html.user.settings(request.user.asInstanceOf[User]))
  }

  def listRepositories = Authenticated{ implicit request =>
    Ok(Json.toJson(request.user.repositories))
  }

  def createAccessKey() = Authenticated.async {
    implicit request =>
      val a = User.generateAccessKey
      val user = request.user
      for {
        _ <- UserDAO.setAccessKey(user, a)
      } yield {
        UserCache.removeUserFromCache(user.userId)
        JsonOk("A new access key was created.")
      }
  }
}
