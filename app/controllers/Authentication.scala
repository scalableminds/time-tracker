/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package controllers

import play.api.mvc.Action
import play.api.libs.ws.WS
import play.api.Play
import play.api.http.Status._
import play.api.http.HeaderNames._
import play.api.http.MimeTypes
import play.api.libs.json.{JsError, JsSuccess}
import net.liftweb.common.{Failure, Full}
import braingames.util.{FoxImplicits, Fox}
import models.auth.AccessToken
import java.util.UUID
import play.api.cache.Cache
import play.api.Play.current
import play.api.libs.concurrent.Execution.Implicits._

object Authentication extends Controller {

  val config = Play.current.configuration

  val host = config.getString("host.url").get

  val defaultRedirectUri = host + "/" + controllers.routes.Application.index().url

  val authCompleteUrl = "http://localhost:9000/authorization/complete"

  val minScope = List("user")

  val normalScope = List("user")

  def complete(state: String, code: String) = Action {
    implicit request =>
      GithubOauth.requestAccessToken(code, Nil).map{ token =>

      }

      Ok
  }

  def authenticate(redirectUri: Option[String]) = Action{ implicit request =>
    val cacheId = RedirectionCache.store(redirectUri getOrElse defaultRedirectUri)
    val authWithPrivateScope = GithubOauth.authorizeUrl(cacheId, minScope, authCompleteUrl)
    val authWithPublicScope = GithubOauth.authorizeUrl(cacheId, normalScope, authCompleteUrl)
    Ok(views.html.login(authWithPrivateScope, authWithPublicScope))
  }

  def redirectToLogin = Action { implicit request =>
    Redirect(controllers.routes.Authentication.authenticate(Some(host + "/" + request.uri)))
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
      if (response.status == OK) {
        response.json.validate(AccessToken.accessTokenReads) match {
          case JsSuccess(token, _) =>
            Full(token)
          case f: JsError =>
            Failure("Requesting access token resulted in invalid json returned. " + f)
        }
      } else
        Failure(s"Requesting access token resulted in status ${response.status}. Body: ${response.body}")
    }
  }

  def authorizeUrl(state: String, scopes: List[String], redirectUri: String) =
    s"https://github.com/login/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&scope=${scopes.mkString(",")}state=$state"
}