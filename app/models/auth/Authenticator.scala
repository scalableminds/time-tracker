/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models.auth

import org.joda.time.DateTime
import models.{UserDAO, BasicReactiveDAO}
import com.scalableminds.util.reactivemongo.DBAccessContext
import play.api.libs.json._
import play.api.libs.functional.syntax._

case class Authenticator(id: String, userId: String, creationDate: DateTime, lastUsed: DateTime, expirationDate: DateTime)

object UserCookieDAO extends BasicReactiveDAO[Authenticator]{
  val collectionName = "userCookies"

  def refreshCookie(a: Authenticator)(implicit ctx: DBAccessContext) = {
    update(Json.obj("id" -> a.id), formatter.writes(a), upsert = true, multi = false)
  }

  implicit val formatter: OFormat[Authenticator] =
    ((__ \ "id").format[String] and
      (__ \ "userId").format[String] and
      (__ \ "creationDate").format[DateTime] and
      (__ \ "lastUsed").format[DateTime] and
      (__ \ "expirationDate").format[DateTime])(Authenticator.apply _, unlift(Authenticator.unapply))
}
