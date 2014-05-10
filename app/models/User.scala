/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package models

import java.util.UUID
import play.api.libs.json._
import braingames.reactivemongo.{DBAccessContextPayload, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import models.auth.AccessToken
import play.api.libs.functional.syntax._

import braingames.util.Fox

case class User(userId: Int,
  profile: UserProfile,
  authInfo: AccessToken,
  repositories: List[RepositoryAccess],
  settings: JsValue,
  accessKey: Option[String]) extends DBAccessContextPayload {

  val avatarUrl = None

  def githubAccessToken = authInfo.accessToken

  def adminRepositories = repositories.filter(_.isAdmin)

  def pushRepositories = repositories.filter(_.isPusher)

  def namesOfPushRepositories = pushRepositories.map(_.name)

  def namesOfAdminRepositories = adminRepositories.map(_.name)

  def isAdminOf(repo: Repository): Boolean =
    isAdminOf(repo.name)

  def isAdminOf(repoName: String): Boolean =
    adminRepositories.exists(_.name == repoName)

  def isCollaboratorOf(repo: Repository): Boolean =
    isCollaboratorOf(repo.name)

  def isCollaboratorOf(repoName: String): Boolean =
    pushRepositories.exists(_.name == repoName)
}

object User {
  def generateAccessKey = UUID.randomUUID().toString.replace("-", "")

  implicit val userFormat = Json.format[User]

  val loggedInUserWrites: Writes[User] =
    ((__ \ 'id).write[Int] and
      (__ \ 'profile).write[UserProfile] and
      (__ \ 'accessKey).write[Option[String]] and
      (__ \ 'settings).write[JsValue])(u => (u.userId, u.profile, u.accessKey, u.settings))

  val publicUserWrites: Writes[User] =
    ((__ \ 'id).write[Int] and
      (__ \ 'fullName).write[String])(u => (u.userId, u.profile.fullName))
}

object UserDAO extends BasicReactiveDAO[User] {
  val collectionName = "users"

  implicit val formatter = User.userFormat

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

  def findConnectedTo(repositoryName: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(Json.obj("repositories.name" -> repositoryName))
    .cursor[User]
    .collect[List]()
  }

  def updateRepositories(userId: Int, repositories: List[RepositoryAccess])(implicit ctx: DBAccessContext) = {
    findAndModify(findByUserIdQ(userId),
      Json.obj(
        "$set" -> Json.obj("repositories" -> repositories)), returnNew = true)
  }

  def updateSettings(userId: Int, settings: JsValue)(implicit ctx: DBAccessContext) = {
    findAndModify(findByUserIdQ(userId),
      Json.obj(
        "$set" -> Json.obj("settings" -> settings)), returnNew = true)
  }

  def update(userId: Int, profile: UserProfile, authInfo: AccessToken)(implicit ctx: DBAccessContext): Fox[User] = {
    findAndModify(findByUserIdQ(userId),
      Json.obj(
        "$set" -> Json.obj(
          "profile" -> profile, "authInfo" -> authInfo),
        "$setOnInsert" -> Json.obj(
          "userId" -> userId,
          "repositories" -> Json.arr(),
          "settings" -> Json.obj()
        )), upsert = true, returnNew = true)
  }

  def setAccessKey(user: User, accessKey: String)(implicit ctx: DBAccessContext) = {
    update(findByUserIdQ(user.userId), Json.obj("$set" -> Json.obj("accessKey" -> accessKey)))
  }
}