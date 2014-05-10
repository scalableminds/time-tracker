/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package controllers

import scala.None
import models.{RepositoryDAO, RepositoryAccess, UserDAO, User}
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.json.Writes
import models.auth.{UserService, UserCache}
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

  def readMyself = Authenticated{ implicit request =>
    Ok(User.loggedInUserWrites.writes(request.user))
  }

  def updateSettings = Authenticated.async(parse.json(1024)){ implicit request =>
    for{
      user <- UserService.updateSettings(request.user.userId, request.body) ?~> "Settings update failed"
    } yield {
      JsonOk("Settings updated")
    }
  }

  def readSettings = Authenticated{
    implicit request =>
      Ok(request.user.settings)
  }

  def listRepositories = Authenticated.async{ implicit request =>
    UsingFilters[RepositoryAccess](
      Filter("isAdmin", (isAdmin: Boolean, repoAccess) => repoAccess.isAdmin == isAdmin)
    ){ filter =>
      for{
        usedRepositories <- RepositoryDAO.findAll
      } yield {
        Ok(Json.toJson(filter.applyOn(request.user.repositories.filterNot(r => usedRepositories.exists(_.name == r.name)))))
      }
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
        JsonOk("A new access key was created")
      }
  }
}
