package models

import _root_.java.util.UUID
import reactivemongo.bson.BSONObjectID
import play.api.libs.json._
import play.modules.reactivemongo.json.BSONFormats._
import braingames.reactivemongo.{DBAccessContextPayload, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import securesocial.core._
import securesocial.core.OAuth2Info
import securesocial.core.OAuth1Info
import securesocial.core.PasswordInfo
import play.api.libs.json.JsObject
import play.api.Logger

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 22:36
 */

object UserFactory {
  def apply(i: Identity): User = {
    User(
      i.identityId, i.firstName, i.lastName, i.fullName,
      i.email, i.authMethod, i.oAuth1Info,
      i.oAuth2Info, i.passwordInfo)
  }
}

case class User(identityId: IdentityId,
                firstName: String,
                lastName: String,
                fullName: String,
                email: Option[String],
                authMethod: AuthenticationMethod,
                oAuth1Info: Option[OAuth1Info],
                oAuth2Info: Option[OAuth2Info],
                passwordInfo: Option[PasswordInfo],
                accessKey: Option[String] = None) extends Identity with DBAccessContextPayload {

  val avatarUrl = None

  val githubId = identityId.userId

  def nick = User.generateNick(fullName)

  def githubAccessToken = oAuth2Info.get.accessToken
}

object User {
  def generateAccessKey = UUID.randomUUID().toString.replace("-", "")

  def generateNick(fullName: String) = {
    val vocals = List('a', 'o', 'i', 'e', 'u')
    val nameV = fullName.toLowerCase.split(' ').flatMap(_.find(vocals.contains))
    val nameK = fullName.toLowerCase.split(' ').flatMap(_.find(c => !vocals.contains(c)))

    val vocalsToUse = (nameV ++ vocals).toList
    val konsToUse = (nameK ++ List('l', 'w', 'z', 'r')).take(2)

    konsToUse.foldLeft(("", vocalsToUse)) {
      case ((s, v :: vs), k) =>
        (s + k + v, vs)
      case ((s, Nil), k) =>
        (s + k, Nil)
    }._1
  }
}

object UserDAO extends BasicReactiveDAO[User] {
  val collectionName = "users"

  def findOneByEmail(email: String)(implicit ctx: DBAccessContext) = findHeadOption("email", email)

  def findByUserIdQ(identityId: IdentityId) = Json.obj(
    "identityId.userId" -> identityId.userId,
    "identityId.providerId" -> identityId.providerId)

  def findOneByUserId(identityId: IdentityId)(implicit ctx: DBAccessContext) = {
    collectionFind(findByUserIdQ(identityId)).one[User]
  }

  def findByAccessKey(accessKey: String)(implicit ctx: DBAccessContext) = {
    collectionFind(Json.obj("accessKey" -> accessKey)).one[User]
  }

  def findOneByEmailAndProvider(email: String, provider: String)(implicit ctx: DBAccessContext) = {
    collectionFind(Json.obj("email" -> email, "identityId.providerId" -> provider)).one[User]
  }

  def update(i: Identity)(implicit ctx: DBAccessContext) = {
    collectionUpdate(findByUserIdQ(i.identityId),
      Json.obj("$set" -> Json.toJson(UserFactory(i))), upsert = true)
  }

  def setAccessKey(user: User, accessKey: String)(implicit ctx: DBAccessContext) = {
    collectionUpdate(findByUserIdQ(user.identityId), Json.obj("$set" -> Json.obj("accessKey" -> accessKey)))
  }

  def fromIdentity(i: Identity) =
    User(i.identityId, i.firstName, i.lastName, i.fullName, i.email, i.authMethod, i.oAuth1Info, i.oAuth2Info, i.passwordInfo)

  def findOneByGID(gid: String)(implicit ctx: DBAccessContext) = {
    collectionFind(Json.obj("id.userId" -> gid)).one[User]
  }

  implicit val AuthenticationMethodFormat: Format[AuthenticationMethod] =
    Format(Reads.StringReads.map(AuthenticationMethod.apply), Writes {
      am: AuthenticationMethod => Writes.StringWrites.writes(am.method)
    })

  implicit val OAuth1InfoFormat: Format[OAuth1Info] = Json.format[OAuth1Info]

  implicit val OAuth2InfoFormat: Format[OAuth2Info] = Json.format[OAuth2Info]

  implicit val PasswordInfoFormat: Format[PasswordInfo] = Json.format[PasswordInfo]

  implicit val IdentityIdFormat: Format[IdentityId] = Json.format[IdentityId]

  implicit val formatter: OFormat[User] = {
    val f: Reads[User] = Json.reads[User]
    val w: OWrites[User] = OWrites.apply(o => Json.writes[User].writes(o).as[JsObject])
    OFormat.apply[User](f, w)
  }
}