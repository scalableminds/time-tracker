package models

import _root_.java.util.UUID
import reactivemongo.bson.BSONObjectID
import play.api.libs.json._
import play.modules.reactivemongo.json.BSONFormats._
import braingames.reactivemongo.{DBAccessContextPayload, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import securesocial.core._
import securesocial.core.UserId
import securesocial.core.OAuth2Info
import securesocial.core.OAuth1Info
import securesocial.core.PasswordInfo
import play.api.libs.json.JsObject

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 22:36
 */

case class BareUser(id: UserId, firstName: String, lastName: String, fullName: String, email: Option[String],
                      avatarUrl: Option[String], authMethod: AuthenticationMethod,
                      oAuth1Info: Option[OAuth1Info] = None,
                      oAuth2Info: Option[OAuth2Info] = None,
                      passwordInfo: Option[PasswordInfo] = None)

object BareUserFactory {
  def apply(i: Identity): BareUser = {
    BareUser(
      i.id, i.firstName, i.lastName, i.fullName,
      i.email, i.avatarUrl, i.authMethod, i.oAuth1Info,
      i.oAuth2Info, i.passwordInfo
    )
  }
}

case class User( id: UserId,
                 fullName: String,
                 email: Option[String],
                 authMethod: AuthenticationMethod,
                 oAuth1Info: Option[OAuth1Info],
                 oAuth2Info: Option[OAuth2Info],
                 passwordInfo: Option[PasswordInfo],
                 accessKey: String = User.generateAccessKey) extends Identity with DBAccessContextPayload{
  val firstName = ""
  val lastName = ""
  val avatarUrl = None

  val githubId = id.id

  def githubAccessToken = oAuth2Info.get.accessToken
}

object User{
  def generateAccessKey = UUID.randomUUID().toString.replace("-", "")
}

object UserDAO extends BasicReactiveDAO[User]{
  val collectionName = "users"

  def findOneByEmail(email: String)(implicit ctx: DBAccessContext) = findHeadOption("email", email)

  def findByUserIdQ(userId: UserId)= Json.obj("id.id" -> userId.id, "id.providerId" -> userId.providerId)

  def findOneByUserId(userId: UserId)(implicit ctx: DBAccessContext) = {
    collectionFind(findByUserIdQ(userId)).one[User]
  }

  def findByAccessKey(accessKey: String)(implicit ctx: DBAccessContext) = {
    collectionFind(Json.obj("accessKey" -> accessKey)).one[User]
  }

  def findOneByEmailAndProvider(email: String, provider: String)(implicit ctx: DBAccessContext) = {
    collectionFind(Json.obj("email" -> email, "id.providerId" -> provider)).one[User]
  }

  def update(i: Identity)(implicit ctx: DBAccessContext) = {
    collectionUpdate(findByUserIdQ(i.id),
      Json.obj("$set" -> Json.toJson(BareUserFactory(i))), upsert = true)
  }

  def fromIdentity(i: Identity) =
    User(i.id, i.fullName, i.email, i.authMethod, i.oAuth1Info, i.oAuth2Info, i.passwordInfo )

  def findOneByGID(gid: String)(implicit ctx: DBAccessContext) = {
    collectionFind(Json.obj("id.id" -> gid)).one[User]
  }

  implicit val AuthenticationMethodFormat: Format[AuthenticationMethod] =
    Format(Reads.StringReads.map(AuthenticationMethod.apply), Writes { am: AuthenticationMethod => Writes.StringWrites.writes(am.method) })

  implicit val OAuth1InfoFormat: Format[OAuth1Info] = Json.format[OAuth1Info]

  implicit val OAuth2InfoFormat: Format[OAuth2Info] = Json.format[OAuth2Info]

  implicit val PasswordInfoFormat: Format[PasswordInfo] = Json.format[PasswordInfo]

  implicit val UserIdFormat: Format[UserId] = Json.format[UserId]

  implicit val bareUserFactoryFormat: Format[BareUser] = Json.format[BareUser]

  implicit val formatter: OFormat[User] = {
    val f:Reads[User] = Json.reads[User]
    val w:OWrites[User] = OWrites.apply(o => Json.writes[User].writes(o).as[JsObject])
    OFormat.apply[User](f, w)
  }
}