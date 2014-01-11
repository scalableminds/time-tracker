package models.services

import models.{UserDAO, User}
import braingames.reactivemongo.GlobalDBAccess
import play.api.{Logger, Application}
import securesocial.core.{IdentityId, Identity, UserServicePlugin}
import securesocial.core.providers.Token
import scala.concurrent.duration._
import scala.concurrent.Await

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 23:12
 */
class UserService(application: Application) extends UserServicePlugin(application) with GlobalDBAccess{
  val timeout = 5 seconds

  def find(id: IdentityId): Option[User] = {
    Await.result(UserCache.findUser(id), timeout)
  }

  def findByEmailAndProvider(email: String, providerId: String): Option[User] = {
    Await.result(UserCache.findUser(email, providerId), timeout)
  }

  def save(identity: Identity): User = {
    UserCache.removeUserFromCache(identity.identityId)
    UserDAO.update(identity)
    UserDAO.fromIdentity(identity)
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