package models

import play.api.libs.json.Json
import braingames.reactivemongo.{DefaultAccessDefinitions, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import braingames.reactivemongo.AccessRestrictions._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 22.07.13
 * Time: 01:54
 */
case class Repository(fullName: String) {
  def owner = fullName.split("/").head

  def name = fullName.split("/").last
}

object Repository{

  implicit val repositoryFormat = Json.format[Repository]

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
          AllowIf(Json.obj("fullName" -> Json.obj("$in" -> user.namesOfPushRepositories)))
        case _ =>
          DenyEveryone()
      }
    }
  }

  def findByName(fullName: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(Json.obj("fullName" -> fullName)).one[Repository]
  }

  def removeByName(fullName: String)(implicit ctx: DBAccessContext) = {
    remove(Json.obj(
      "fullName" -> fullName
    ))
  }

  def findAllWhereUserIsAdmin(user: User)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(Json.obj("admins" -> user.userId)).cursor[Repository].collect[List]()
  }

  def updateCollaborators(fullName: String, collaborators: List[String])(implicit ctx: DBAccessContext) = {
    update(
      Json.obj("fullName" -> fullName),
      Json.obj("$set" -> Json.obj("collaborators" -> collaborators))
    )
  }
}
