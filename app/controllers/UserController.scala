package controllers

import scala.None
import models.{RepositoryAccess, UserDAO, User}
import play.api.libs.concurrent.Execution.Implicits._
import models.auth.UserCache
import play.api.libs.json.Json
import braingames.mvc.Filter
import braingames.util.DefaultConverters._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 18.08.13
 * Time: 16:43
 */
object UserController extends Controller {
  val DefaultAccessRole = None

  def showSettings() = Authenticated {
    implicit request =>
      Ok(views.html.user.settings(request.user.asInstanceOf[User]))
  }

  def listRepositories = Authenticated{ implicit request =>
    UsingFilters[RepositoryAccess](
      Filter("isAdmin", (isAdmin: Boolean, repoAccess) => repoAccess == isAdmin)
    ){ filter =>
      Ok(Json.toJson(filter.applyOn(request.user.repositories)))
    }
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
