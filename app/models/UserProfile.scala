/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models

import play.api.libs.json.Json

case class UserProfile(
  login: String,
  firstName: String,
  lastName: String,
  fullName: String,
  email: Option[String])

object UserProfile {
  implicit val userProfileFormat = Json.format[UserProfile]
}