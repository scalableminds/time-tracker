package models

import _root_.java.util.UUID
import play.api.libs.json._
import braingames.reactivemongo.{DBAccessContextPayload, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import models.auth.{AccessToken, OAuth2Info}
import braingames.util.Fox
import reactivemongo.core.commands.LastError

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 22:36
 */

case class UserProfile(
  login: String,
  firstName: String,
  lastName: String,
  fullName: String,
  email: Option[String])

object UserProfile {
  implicit val userProfileFormat = Json.format[UserProfile]
}

case class User(userId: Int,
  profile: UserProfile,
  authInfo: AccessToken,
  accessKey: Option[String]) extends DBAccessContextPayload {

  val avatarUrl = None

  def githubAccessToken = authInfo.accessToken
}

object User {
  def generateAccessKey = UUID.randomUUID().toString.replace("-", "")
}

object UserDAO extends BasicReactiveDAO[User] {
  val collectionName = "users"

  implicit val formatter = Json.format[User]

  def findOneByEmail(email: String)(implicit ctx: DBAccessContext) =
    findHeadOption("profile.email", email)

  def findByUserIdQ(userId: Int) = Json.obj(
    "userId" -> userId)

  def findOneByUserId(userId: Int)(implicit ctx: DBAccessContext) = withExceptionCatcher {
    find(findByUserIdQ(userId)).one[User]
  }

  def findByAccessKey(accessKey: String)(implicit ctx: DBAccessContext) = withExceptionCatcher {
    find(Json.obj("accessKey" -> accessKey)).one[User]
  }

  def update(userId: Int, profile: UserProfile, authInfo: AccessToken)(implicit ctx: DBAccessContext): Fox[User] = {
    findAndModify(findByUserIdQ(userId),
      Json.obj(
        "$set" -> Json.obj(
          "profile" -> profile, "authInfo" -> authInfo),
        "$setOnInsert" -> Json.obj(
          "userId" -> userId
        )), upsert = true, returnNew = true)
  }

  def setAccessKey(user: User, accessKey: String)(implicit ctx: DBAccessContext) = {
    update(findByUserIdQ(user.userId), Json.obj("$set" -> Json.obj("accessKey" -> accessKey)))
  }
}