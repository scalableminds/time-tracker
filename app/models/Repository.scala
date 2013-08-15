package models

import play.api.libs.json.Json
import braingames.reactivemongo.DBAccessContext
import play.api.libs.concurrent.Execution.Implicits._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 22.07.13
 * Time: 01:54
 */
case class Repository(fullName: String, accessToken: String, admins: List[String], collaborators: List[String]) {
  def owner = fullName.split("/").head

  def name = fullName.split("/").last

  def isAdmin(user: User) = {
    admins.contains(user.githubId)
  }
}

object RepositoryDAO extends BasicReactiveDAO[Repository] {
  val collectionName = "repositories"

  override def findQueryFilter(implicit ctx: DBAccessContext) = {
    AllowIf(Json.obj("collaborators" -> "1337"))
  }

  def createFullName(owner: String, repo: String) =
    owner + "/" + repo

  implicit val formatter = Json.format[Repository]

  def findByName(fullName: String)(implicit ctx: DBAccessContext) = {
    collectionFind(Json.obj("fullName" -> fullName)).one[Repository]
  }

  def removeByName(fullName: String)(implicit ctx: DBAccessContext) = {
    collectionRemove(Json.obj(
      "fullName" -> fullName
    ))
  }

  def updateCollaborators(fullName: String, collaborators: List[String])(implicit ctx: DBAccessContext) = {
    collectionUpdate(
      Json.obj("fullName" -> fullName),
      Json.obj("$set" -> Json.obj("collaborators" -> collaborators))
    )
  }
}
