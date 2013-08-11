package models.services

import securesocial.core.AuthenticatorStore
import securesocial.core.Authenticator
import scala.concurrent.Await
import scala.concurrent.duration._
import models.UserCookieDAO
import braingames.reactivemongo.GlobalDBAccess
import play.api.Logger

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 20.07.13
 * Time: 00:49
 */


class MongoAuthenticatorStore(app: play.api.Application) extends AuthenticatorStore(app) with GlobalDBAccess{
  def save(authenticator: Authenticator): Either[Error, Unit] = {
    UserCookieDAO.refreshCookie(authenticator)
    Right(())
  }

  def find(id: String): Either[Error, Option[Authenticator]] = {
    Right(Await.result(UserCookieDAO.findHeadOption("id", id), 5 seconds))
  }

  def delete(id: String): Either[Error, Unit] = {
    UserCookieDAO.remove("id", id)
    Right(())
  }
}