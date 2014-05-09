package models.auth

import models._
import braingames.reactivemongo.{DBAccessContext, GlobalAccessContext, GlobalDBAccess}
import play.api.Application
import scala.concurrent.duration._
import scala.concurrent.Await
import braingames.util.Fox
import play.api.libs.json.{JsValue, JsObject}

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 23:12
 */
object UserService{

  def find(userId: Int): Fox[User] = {
    UserCache.findUser(userId)
  }

  def findByEmail(email: String): Fox[User] = {
    UserDAO.findOneByEmail(email)(GlobalAccessContext)
  }

  def save(userId: Int, profile: UserProfile, authInfo: AccessToken): Fox[User] = {
    UserDAO.update(userId, profile, authInfo)(GlobalAccessContext).map{ user =>
      UserCache.removeUserFromCache(userId)
      user
    }
  }

  def updateRepositories(userId: Int, repositories: List[RepositoryAccess])(implicit ctx: DBAccessContext) = {
    UserDAO.updateRepositories(userId, repositories).map{ user =>
      UserCache.removeUserFromCache(userId)
      user
    }
  }

  def updateSettings(userId: Int, settings: JsValue)(implicit ctx: DBAccessContext) = {
    UserDAO.updateSettings(userId, settings).map{ user =>
      UserCache.removeUserFromCache(userId)
      user
    }
  }

  def findCollaboratorsOf(repository: Repository) = {
    UserDAO
    .findConnectedTo(repository.name)(GlobalAccessContext)
    .map(users => users.filter(user => user.isCollaboratorOf(repository.name)))
  }

  def findAdminsOf(repository: Repository) = {
    UserDAO
    .findConnectedTo(repository.name)(GlobalAccessContext)
    .map(users => users.filter(user => user.isAdminOf(repository.name)))
  }

  def extractName(s: String) = {
    s.split(" ") match{
      case Array(first, last@_*) =>
        (first, last.mkString(" "))
      case _ =>
        ("", "")
    }
  }
}