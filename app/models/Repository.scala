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
case class Repository(fullName: String, accessToken: String, admins: List[Int], collaborators: List[Int]) {
  def owner = fullName.split("/").head

  def name = fullName.split("/").last

  def isAdmin(user: User) = {
    admins.contains(user.userId)
  }

  def isCollaborator(user: User) = {
    collaborators.contains(user.userId)
  }
}

object RepositoryDAO extends BasicReactiveDAO[Repository] {
  val collectionName = "repositories"

  override val AccessDefinitions = new DefaultAccessDefinitions {
    override def findQueryFilter(implicit ctx: DBAccessContext) = {
      ctx.data match {
        case Some(user: User) =>
          AllowIf(Json.obj("$or" -> List(
            Json.obj("collaborators" -> user.userId),
            Json.obj("admins" -> user.userId))))
        case _ if ctx.globalAccess =>
          AllowEveryone
        case _ =>
          DenyEveryone()

      }
    }
  }

  def createFullName(owner: String, repo: String) =
    owner + "/" + repo

  implicit val formatter = Json.format[Repository]

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
