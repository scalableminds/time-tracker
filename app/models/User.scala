package models

import _root_.java.util.UUID
import play.api.libs.json._
import braingames.reactivemongo.{DBAccessContextPayload, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import models.auth.OAuth2Info

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 22:36
 */

case class UserProfile(firstName: String,
                        lastName: String,
                        fullName: String,
                        email: Option[String])

object UserProfile{
  implicit val userProfileFormat = Json.format[UserProfile]
}

case class User(userId: String,
                profile: UserProfile,
                oAuth2Info: OAuth2Info,
                accessKey: Option[String]) extends DBAccessContextPayload {

  val avatarUrl = None

  def githubAccessToken = oAuth2Info.accessToken
}

object User {
  def generateAccessKey = UUID.randomUUID().toString.replace("-", "")
}

object UserDAO extends BasicReactiveDAO[User] {
  val collectionName = "users"

  implicit val formatter = Json.format[User]

  def findOneByEmail(email: String)(implicit ctx: DBAccessContext) =
    findHeadOption("profile.email", email)

  def findByUserIdQ(userId: String) = Json.obj(
    "userId" -> userId)

  def findOneByUserId(userId: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(findByUserIdQ(userId)).one[User]
  }

  def findByAccessKey(accessKey: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(Json.obj("accessKey" -> accessKey)).one[User]
  }

  /*def update(i: Identity)(implicit ctx: DBAccessContext): Fox[LastError] = {
    update(findByUserIdQ(i.identityId),
      Json.obj("$set" -> Json.toJson(UserFactory(i))), upsert = true)
  } */

  def setAccessKey(user: User, accessKey: String)(implicit ctx: DBAccessContext) = {
    update(findByUserIdQ(user.userId), Json.obj("$set" -> Json.obj("accessKey" -> accessKey)))
  }

  //def fromIdentity(i: Identity) =
  //  User(i.identityId, i.firstName, i.lastName, i.fullName, i.email, i.authMethod, i.oAuth1Info, i.oAuth2Info, i.passwordInfo)
}