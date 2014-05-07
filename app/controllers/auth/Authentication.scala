/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package controllers.auth

import play.api.mvc.Action
import play.api.libs.ws.WS
import play.api.{Logger, Play}
import play.api.http.Status._
import play.api.http.HeaderNames._
import play.api.http.MimeTypes
import play.api.libs.json.{JsError, JsSuccess}
import net.liftweb.common.{Failure, Full}
import braingames.util.{FoxImplicits, Fox}
import models.auth.{SessionService, UserService, AccessToken}
import java.util.UUID
import play.api.cache.Cache
import play.api.Play.current
import play.api.libs.concurrent.Execution.Implicits._
import models.UserProfile
import controllers.{GithubApi, Controller}

object Authentication extends Controller {

  val config = Play.current.configuration

  val defaultRedirectUri = host + controllers.routes.Application.index().url

  val authCompleteUrl = "http://localhost:9000/authenticate/complete"

  val minScope = List("user")

  val normalScope = List("user")

  def complete(state: String, code: String) = Action.async {
    implicit request =>
      GithubOauth.requestAccessToken(code, Nil).flatMap { token =>
        GithubApi.userDetails(token.accessToken).toFox.flatMap { userDetails =>
          val (first, last) = UserService.extractName(userDetails.name)
          val profile = UserProfile(userDetails.login, first, last, userDetails.name, Option(userDetails.email))
          Logger.info("About to save user. " + token)
          UserService.save(userDetails.id, profile, token)
        }
      }.futureBox.map{
        case Full(user) =>
          Logger.info("Saved user. " + user)
          val redirectUri = RedirectionCache.retrieve(state) getOrElse defaultRedirectUri
          Redirect(redirectUri).withSession(Secured.createSession(user))
        case x =>
          Logger.info("Saving user failed. " + x)
          BadRequest("Failed to complete github auth.")
      }
  }

  def authenticate(redirectUri: Option[String]) = Action{ implicit request =>
    val cacheId = RedirectionCache.store(redirectUri getOrElse defaultRedirectUri)
    val authWithPrivateScope = GithubOauth.authorizeUrl(cacheId, minScope, authCompleteUrl)
    val authWithPublicScope = GithubOauth.authorizeUrl(cacheId, normalScope, authCompleteUrl)
    Ok(views.html.login(authWithPrivateScope, authWithPublicScope))
  }

  def logout = Authenticated.async{ implicit request =>
    for {
      _ <- SessionService.removeSessions(request.user.userId)
    } yield {
        Redirect(controllers.routes.Application.index())
    }
  }
}

object RedirectionCache{
  def cacheKey(id: String) =
    s"redirectUri-$id"

  def store(redirectUri: String): String = {
    val id = UUID.randomUUID().toString
    Cache.set(cacheKey(id), redirectUri)
    id
  }

  def retrieve(id: String): Option[String] = {
    Cache.getAs[String](cacheKey(id))
  }
}

object GithubOauth extends FoxImplicits {

  val config = Play.current.configuration
  val secret = config.getString("authentication.github.secret").get
  val clientId = config.getString("authentication.github.clientId").get

  def requestAccessToken(code: String, minScope: List[String]): Fox[AccessToken] = {
    WS
    .url("https://github.com/login/oauth/access_token")
    .withHeaders(ACCEPT -> MimeTypes.JSON)
    .withQueryString(
        "client_id" -> clientId,
        "client_secret" -> secret,
        "code" -> code
      )
    .post("")
    .map { response =>
      Logger.info("Response code from accesstoken request: " + response.status + " Body: " + response.body)
      if (response.status == OK) {
        response.json.validate(AccessToken.accessTokenGithubReads) match {
          case JsSuccess(token, _) =>
            Logger.info("Got a response token.")
            Full(token)
          case f: JsError =>
            Logger.warn("Failed to parse response token. " + f)
            Failure("Requesting access token resulted in invalid json returned. " + f)
        }
      } else
        Failure(s"Requesting access token resulted in status ${response.status}. Body: ${response.body}")
    }
  }

  def authorizeUrl(state: String, scopes: List[String], redirectUri: String) =
    s"https://github.com/login/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&scope=${scopes.mkString(",")}&state=$state"
}