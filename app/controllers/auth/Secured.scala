/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package controllers.auth

import play.api.mvc._
import play.api.mvc.Request
import scala.concurrent.Future
import com.scalableminds.util.tools.{FoxImplicits, Fox}
import net.liftweb.common.{Full, Empty}
import play.api.libs.concurrent.Execution.Implicits._
import com.scalableminds.util.reactivemongo.GlobalAccessContext
import models.User
import models.auth.SessionService
import play.api.Play
import play.api.mvc.Results._
import scala.concurrent.duration._

class AuthenticatedRequest[A](
  val user: User, override val request: Request[A]
  ) extends UserAwareRequest(Some(user), request)

class UserAwareRequest[A](
  val userOpt: Option[User], val request: Request[A]
  ) extends WrappedRequest(request)


object Secured {
  /**
   * Key used to store authentication information in the client cookie
   */
  val SessionInformationKey = "time-tracker-session"

  val CookieLifeTime = (365 days).toSeconds.toInt

  /**
   * Creates a map which can be added to a cookie to set a session
   */
  def createCookie(user: User): Cookie = {
    val token = SessionService.createSession(user.userId)(GlobalAccessContext)
    Cookie(SessionInformationKey, token, maxAge = Some(CookieLifeTime))
  }

  def discardCookie =
    DiscardingCookie(SessionInformationKey)
}

/**
 * Provide security features
 */
trait Secured extends FoxImplicits {
  /**
   * Defines the access role which is used if no role is passed to an
   * authenticated action
   */
  val userService = models.auth.UserService

  val host = Play.current.configuration.getString("host.url").get

  private def userFromSession(implicit request: RequestHeader): Fox[User] =
    request.cookies.get(Secured.SessionInformationKey) match {
      case Some(cookie) =>
        SessionService.resolve(cookie.value)(GlobalAccessContext)
      case _ =>
        Empty
    }

  /**
   * Awesome construct to create an authenticated action. It uses the helper
   * function defined below this one to ensure that a user is logged in. If
   * a user fails this check he is redirected to the result of 'onUnauthorized'
   *
   * Example usage:
   * def initialize = Authenticated( role=Admin ) { user =>
   * implicit request =>
   * Ok("User is logged in!")
   * }
   *
   */

  object Authenticated extends ActionBuilder[AuthenticatedRequest]{
    def invokeBlock[A](request: Request[A], block: (AuthenticatedRequest[A]) => Future[Result]) = {
      userFromSession(request).flatMap { user =>
        block(new AuthenticatedRequest(user, request))
      }.getOrElse(onUnauthorized(request))
    }
  }

  object UserAwareAction extends ActionBuilder[UserAwareRequest] {
    def invokeBlock[A](request: Request[A], block: (UserAwareRequest[A]) => Future[Result]) = {
      userFromSession(request).futureBox.flatMap {
        case Full(user) =>
          block(new AuthenticatedRequest(user, request))
        case _ =>
          block(new UserAwareRequest(None, request))
      }
    }
  }

  /**
   * Redirect to login if the user in not authorized.
   */
  private def onUnauthorized(request: RequestHeader) =
    Redirect(controllers.auth.routes.Authentication.authenticate(Some(host + request.uri)))
}
