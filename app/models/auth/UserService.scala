package models.auth

import models.{UserProfile, UserDAO, User}
import braingames.reactivemongo.GlobalDBAccess
import play.api.Application
import scala.concurrent.duration._
import scala.concurrent.Await
import braingames.util.Fox

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 23:12
 */
object UserService extends GlobalDBAccess{

  def find(userId: Int): Fox[User] = {
    UserCache.findUser(userId)
  }

  def findByEmail(email: String): Fox[User] = {
    UserDAO.findOneByEmail(email)
  }

  def save(userId: Int, profile: UserProfile, authInfo: AccessToken): Fox[User] = {
    UserCache.removeUserFromCache(userId)
    UserDAO.update(userId, profile, authInfo)
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