package controllers

import play.api.mvc.{Controller => PlayController, Request}
import braingames.mvc.ExtendedController
import braingames.reactivemongo.{AuthorizedAccessContext, DBAccessContext}
import securesocial.core.{RequestWithUser, SecuredRequest}
import models.User
import play.api.mvc.Flash
import play.api.mvc.Request
import play.api.mvc.RequestHeader

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 14:39
 */
trait Controller extends PlayController with ExtendedController with ProvidesAccessContext with ProvidesSessionData


trait ProvidesAccessContext{
  implicit def securedRequestToDBAccess(implicit request: SecuredRequest[_]): DBAccessContext = {
    AuthorizedAccessContext(request.user.asInstanceOf[User])
  }

  implicit def userToDBAccess(user: User): DBAccessContext = {
    AuthorizedAccessContext(user)
  }
}

case class UnAuthedSessionData(request: RequestHeader) extends SessionData {
  val userOpt = None
}

case class AuthedSessionData(user: User, request: RequestHeader) extends SessionData {
  val userOpt = Some(user)
}

case class UserAwareSessionData(userOpt: Option[User], request: RequestHeader) extends SessionData

trait SessionData {
  def userOpt: Option[User]
  implicit def request: RequestHeader
  def flash: Flash = request.flash
}

trait ProvidesSessionData {

  implicit def sessionDataAuthenticated[A](implicit request: SecuredRequest[A]): AuthedSessionData = {
    AuthedSessionData(request.user.asInstanceOf[User], request)
  }

  implicit def sessionData[A](implicit request: Request[A]): SessionData = {
    request match {
      case r: SecuredRequest[A] =>
        UserAwareSessionData(Some(r.user.asInstanceOf[User]), request)
      case r: RequestWithUser[A] =>
        UserAwareSessionData(r.user.map(_.asInstanceOf[User]), request)

      case _ =>
        UnAuthedSessionData(request)
    }
  }
}
