/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models.auth

case class AccessToken(accessToken: String, scope: String, tokenType: String)

object AccessToken {

  import play.api.libs.json._
  import play.api.libs.functional.syntax._

  implicit val accessTokenReads: Reads[AccessToken] =
    ((__ \ 'access_token).read[String] and
      (__ \ 'scope).read[String] and
      (__ \ 'tokenType).read[String])(AccessToken.apply _)
}
