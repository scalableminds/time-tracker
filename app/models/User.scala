package models

import reactivemongo.bson.BSONObjectID
import play.api.libs.json._
import play.modules.reactivemongo.json.BSONFormats._
import braingames.reactivemongo.{ DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import securesocial.core._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 22:36
 */

case class User( id: UserId,
                 firstName: String,
                 lastName: String,
                 email: Option[String],
                 authMethod: AuthenticationMethod,
                 oAuth1Info: Option[OAuth1Info],
                 oAuth2Info: Option[OAuth2Info],
                 passwordInfo: Option[PasswordInfo]) extends Identity {

  val fullName: String = s"$firstName $lastName"
  val avatarUrl = None

  def githubAccessToken = oAuth2Info.get.accessToken
}

object UserDAO extends BasicReactiveDAO[User]{
  val collectionName = "users"

  def findOneByEmail(email: String)(implicit ctx: DBAccessContext) = findHeadOption("email", email)

  def findByUserIdQ(userId: UserId)= Json.obj("id.id" -> userId.id, "id.providerId" -> userId.providerId)

  def findOneByUserId(userId: UserId)(implicit ctx: DBAccessContext) = {
    collectionFind(findByUserIdQ(userId)).one[User]
  }

  def findOneByEmailAndProvider(email: String, provider: String)(implicit ctx: DBAccessContext) = {
    collectionFind(Json.obj("email" -> email, "id.providerId" -> provider)).one[User]
  }

  def update(i: Identity)(implicit ctx: DBAccessContext) = {
    collectionUpdate(findByUserIdQ(i.id),
      Json.obj("$set" -> Json.toJson(fromIdentity(i))), upsert = true)
  }

  def fromIdentity(i: Identity): User = {
    User(i.id, i.firstName, i.lastName, i.email, i.authMethod, i.oAuth1Info, i.oAuth2Info, i.passwordInfo)
  }

  implicit val AuthenticationMethodFormat: Format[AuthenticationMethod] =
    Format(Reads.StringReads.map(AuthenticationMethod.apply), Writes { am: AuthenticationMethod => Writes.StringWrites.writes(am.method) })

  implicit val OAuth1InfoFormat: Format[OAuth1Info] = Json.format[OAuth1Info]

  implicit val OAuth2InfoFormat: Format[OAuth2Info] = Json.format[OAuth2Info]

  implicit val PasswordInfoFormat: Format[PasswordInfo] = Json.format[PasswordInfo]

  implicit val UserIdFormat: Format[UserId] = Json.format[UserId]

  implicit val formatter: OFormat[User] = {
    val f:Reads[User] = Json.reads[User]
    val w:OWrites[User] = OWrites.apply(o => Json.writes[User].writes(o).as[JsObject])
    OFormat.apply[User](f, w)
  }
}