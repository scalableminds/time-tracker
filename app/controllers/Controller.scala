/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package controllers

import play.api.mvc.{Controller => PlayController, Request}
import braingames.mvc.ExtendedController
import braingames.reactivemongo.{AuthorizedAccessContext, DBAccessContext}
import models.User
import play.api.mvc.Flash
import play.api.mvc.Request
import play.api.mvc.RequestHeader
import controllers.auth.{UserAwareRequest, AuthenticatedRequest, Secured}

trait Controller extends PlayController with ExtendedController with ProvidesAccessContext with ProvidesSessionData with Secured


trait ProvidesAccessContext{
  implicit def securedRequestToDBAccess(implicit request: AuthenticatedRequest[_]): DBAccessContext = {
    AuthorizedAccessContext(request.user)
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

  implicit def sessionDataAuthenticated[A](implicit request: AuthenticatedRequest[A]): AuthedSessionData = {
    AuthedSessionData(request.user, request)
  }

  implicit def sessionData[A](implicit request: Request[A]): SessionData = {
    request match {
      case r: AuthenticatedRequest[A] =>
        UserAwareSessionData(Some(r.user.asInstanceOf[User]), request)
      case r: UserAwareRequest[A] =>
        UserAwareSessionData(r.userOpt, request)
      case _ =>
        UnAuthedSessionData(request)
    }
  }
}
