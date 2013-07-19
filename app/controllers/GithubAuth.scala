package controllers

import play.api.Play.current

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 23:49
 */
object GithubAuth {
  lazy val conf = current.configuration
  lazy val clientId = conf.getString("github.clientId").get
  lazy val clientSecret = conf.getString("github.clientSecret").get
  lazy val redirectUri = conf.getString("github.redirectUri").get
  lazy val scope = conf.getString("github.scope").get
}
