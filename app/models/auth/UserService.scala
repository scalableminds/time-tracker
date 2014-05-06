package models.auth

import models.{UserDAO, User}
import braingames.reactivemongo.GlobalDBAccess
import play.api.Application
import securesocial.core.{IdentityId, Identity, UserServicePlugin}
import securesocial.core.providers.Token
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

  def find(userId: String): Fox[User] = {
    UserCache.findUser(userId)
  }

  def findByEmail(email: String): Fox[User] = {
    UserDAO.findOneByEmail(email)
  }

  def save(userId: String): Unit = {
    UserCache.removeUserFromCache(userId)
    //UserDAO.update(identity)
    //UserDAO.fromIdentity(identity)
  }


  def save(token: Token) = {

  }

  def findToken(token: String): Option[Token] = {
    None
  }

  def deleteToken(uuid: String) = {

  }

  def deleteExpiredTokens() {
    // implement me
  }
}