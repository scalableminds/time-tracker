/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package controllers.auth

import play.api.mvc.Action
import play.api.{Logger, Play}
import models.auth._
import play.api.libs.concurrent.Execution.Implicits._
import models.{GithubUpdateActor, RepositoryAccess, UserProfile}
import controllers.Controller
import net.liftweb.common.Full
import com.scalableminds.util.reactivemongo.GlobalAccessContext
import com.scalableminds.util.auth.GithubOauth
import com.scalableminds.util.github.GithubApi

object Authentication extends GithubOauth with Controller {

  val config = Play.current.configuration

  val defaultRedirectUri = host + controllers.routes.Application.index().url

  val authCompleteUrl = host + "/authenticate/complete"

  val minScope = List("write:repo_hook, read:org")

  val normalScope = List("repo, read:org")

  lazy val secret = config.getString("authentication.github.secret").get

  lazy val clientId = config.getString("authentication.github.clientId").get

  def complete(state: String, code: String) = Action.async {
    implicit request =>
      requestAccessToken(code, Nil).flatMap { token =>
        for {
          userDetails <- GithubApi.userDetails(token.accessToken).toFox
          (first, last) = UserService.extractName(userDetails.name getOrElse "")
          profile = UserProfile(userDetails.login, first, last, userDetails.name getOrElse "", userDetails.email)
          user <- UserService.save(userDetails.id, profile, token)
        } yield {
          GithubUpdateActor.updateUserRepositories(user, token)
          user
        }
      }.futureBox.map{
        case Full(user) =>
          if (user.authInfo.scope == "") {
            Redirect("/reauthorize")
          } else {
            val redirectUri = RedirectionCache.retrieve(state) getOrElse defaultRedirectUri
            Redirect(redirectUri).withCookies(Secured.createCookie(user))
          }

        case x =>
          Logger.debug("Saving user failed. " + x)
          BadRequest("Failed to complete github auth.")
      }
  }

  def authenticate(redirectUri: Option[String]) = Action{ implicit request =>
    val cacheId = RedirectionCache.store(redirectUri getOrElse defaultRedirectUri)
    val authWithEmptyScope = authorizeUrl(cacheId, authCompleteUrl)
    Redirect(authWithEmptyScope)
  }

  def reauthorize(redirectUri: Option[String]) = UserAwareAction{ implicit request =>
    val cacheId = RedirectionCache.store(redirectUri getOrElse defaultRedirectUri)
    val authWithPrivateScope = authorizeUrl(cacheId, normalScope, authCompleteUrl)
    val authWithPublicScope = authorizeUrl(cacheId, minScope, authCompleteUrl)

    Ok(views.html.login(authWithPrivateScope, authWithPublicScope))
  }

  def logout = Authenticated.async{ implicit request =>
    for {
      _ <- SessionService.removeSessions(request.user.userId)
    } yield {
        Redirect(controllers.routes.Application.index()).discardingCookies(Secured.discardCookie)
    }
  }
}