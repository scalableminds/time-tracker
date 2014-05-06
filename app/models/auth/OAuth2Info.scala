/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models.auth

import play.api.libs.json.{Json, Format}

case class OAuth2Info(accessToken: String, tokenType: Option[String] = None,
                      expiresIn: Option[Int] = None, refreshToken: Option[String] = None)

object OAuth2Info{
  implicit val OAuth2InfoFormat: Format[OAuth2Info] = Json.format[OAuth2Info]
}