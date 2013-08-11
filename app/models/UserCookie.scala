package models

import securesocial.core.{UserId, Authenticator}
import play.api.libs.json.Json._
import play.api.libs.json._
import play.api.libs.functional.syntax._
import org.joda.time.DateTime
import play.api.Logger
import reactivemongo.core.commands.GetLastError
import braingames.reactivemongo.DBAccessContext

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 20.07.13
 * Time: 00:49
 */

object UserCookieDAO extends BasicReactiveDAO[Authenticator]{
  val collectionName = "userCookies"

  import UserDAO._

  def refreshCookie(a: Authenticator)(implicit ctx: DBAccessContext) = {
    collectionUpdate(Json.obj("userId" -> a.id), formatter.writes(a), true, false)
  }

  import UserDAO._
  implicit val formatter: OFormat[Authenticator] =
    ((__ \ "id").format[String] and
      (__ \ "userId").format[UserId] and
      (__ \ "creationDate").format[DateTime] and
      (__ \ "lastUsed").format[DateTime] and
      (__ \ "expirationDate").format[DateTime])(Authenticator.apply _, unlift(Authenticator.unapply))
}
