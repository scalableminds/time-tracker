package models

import play.api.libs.json.{JsObject, Writes, Json}
import braingames.reactivemongo.{DefaultAccessDefinitions, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import braingames.reactivemongo.AccessRestrictions._
import reactivemongo.bson.BSONObjectID
import models.auth.UserService
import braingames.util.Fox
import scala.concurrent.Future
import play.modules.reactivemongo.json.BSONFormats._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 22.07.13
 * Time: 01:54
 */
case class Repository(name: String, usesIssueLinks: Boolean, accessToken: Option[String], _id: BSONObjectID = BSONObjectID.generate) {
  def owner = name.split("/").head

  def shortName = name.split("/").last

  def id = _id.stringify
}

object Repository {

  implicit val repositoryFormat = Json.format[Repository]

  def publicRepositoryWrites(repository: Repository): Future[JsObject] = {
    for{
      admins <- UserService.findAdminsOf(repository) getOrElse Nil
    } yield
      Json.obj(
        "name" -> repository.name,
        "usesIssueLinks" -> repository.usesIssueLinks,
        "admins" -> Writes.list(User.publicUserWrites).writes(admins),
        "id" -> repository.id
      )
  }

  def createFullName(owner: String, repo: String) =
    owner + "/" + repo
}

object RepositoryDAO extends BasicReactiveDAO[Repository] {
  val collectionName = "repositories"

  implicit val formatter = Repository.repositoryFormat

  override val AccessDefinitions = new DefaultAccessDefinitions {
    override def findQueryFilter(implicit ctx: DBAccessContext) = {
      ctx.data match {
        case Some(user: User) =>
          AllowIf(Json.obj("name" -> Json.obj("$in" -> user.namesOfPushRepositories)))
        case _ =>
          DenyEveryone()
      }
    }
  }

  def findByName(name: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(Json.obj("name" -> name)).one[Repository]
  }

  def removeByName(name: String)(implicit ctx: DBAccessContext) = {
    remove(Json.obj(
      "name" -> name
    ))
  }

  def findAllWhereUserIsAdmin(user: User)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(Json.obj("admins" -> user.userId)).cursor[Repository].collect[List]()
  }

  def updateCollaborators(name: String, collaborators: List[String])(implicit ctx: DBAccessContext) = {
    update(
      Json.obj("name" -> name),
      Json.obj("$set" -> Json.obj("collaborators" -> collaborators))
    )
  }
}
