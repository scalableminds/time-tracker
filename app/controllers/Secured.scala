package controllers

import play.api.mvc._
import play.api.mvc.BodyParsers
import play.api.mvc.Results._
import play.api.i18n.Messages
import play.api.mvc.Request
import play.api.Play
import play.api.Play.current
import controllers.routes
import play.api.libs.concurrent.Akka
import akka.actor.Props
import models.User
import scala.concurrent.Future
import play.api.libs.concurrent.Execution.Implicits._
import models.services.UserService

case class AuthenticatedRequest[A](val user: User, request: Request[A]) extends WrappedRequest(request)

object Secured {
  /**
   * Key used to store authentication information in the client cookie
   */
  val SessionInformationKey = "userId"

  /**
   * Creates a map which can be added to a cookie to set a session
   */
  def createSession(user: User): Tuple2[String, String] =
    (SessionInformationKey -> user.email)
}

/**
 * Provide security features
 */
trait Secured {

  def DefaultAccessRole: Option[String]

  val userService = models.services.UserService

  def mockUser = {
    if (Play.configuration.getBoolean("application.enableAutoLogin").getOrElse(false))
      Some(Future.successful(Some(UserService.mockUser)))
    else
      None
  }

  /**
   * Tries to extract the user from a request
   */
  def maybeUser(implicit request: RequestHeader): Future[Option[User]] = {
    userId(request).map {
      email =>
        userService.findOneByEmail(email)
    }.orElse(mockUser).getOrElse(Future.successful(None))
  }

  /**
   * Retrieve the connected users email address.
   */
  private def userId(request: RequestHeader) = {
    request.session.get(Secured.SessionInformationKey) match {
      case Some(id) =>
        Some(id)
      case _ =>
        None
    }
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

  def Authenticated[A](
                        parser: BodyParser[A] = BodyParsers.parse.anyContent,
                        role: Option[String] = DefaultAccessRole)(f: AuthenticatedRequest[A] => Result) = {
    Action(parser) {
      request =>
        Async {
          maybeUser(request).map {
            case Some(user) =>
              if (user.verified) {
                if (hasAccess(user, role))
                  f(AuthenticatedRequest(user, request))
                else
                  Forbidden("Forbidden!")
              } else {
                Forbidden("Not verified yet!")
              }
            case _ =>
              onUnauthorized(request)
          }
        }
    }
  }

  def Authenticated(f: AuthenticatedRequest[AnyContent] => Result): Action[AnyContent] = {
    Authenticated(BodyParsers.parse.anyContent)(f)
  }

  def hasAccess(user: User, role: Option[String]) =
    role.map(user.hasRole) getOrElse true

  /**
   * Redirect to login if the user in not authorized.
   */
  private def onUnauthorized(request: RequestHeader) =
    Results.Redirect(routes.Authentication.login)

  // --

  /**
   * Action for authenticated users.
   */
  def IsAuthenticated(f: => String => Request[AnyContent] => Result) =
    Security.Authenticated(userId, onUnauthorized) {
      user =>
        Action(request => f(user)(request))
    }

}
