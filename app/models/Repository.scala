/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package models

import play.api.libs.json._
import com.scalableminds.util.reactivemongo.{DefaultAccessDefinitions, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import com.scalableminds.util.reactivemongo.AccessRestrictions._
import reactivemongo.bson.BSONObjectID
import models.auth.UserService
import com.scalableminds.util.tools.Fox
import scala.concurrent.Future
import play.modules.reactivemongo.json.BSONFormats._
import play.api.libs.functional.syntax._

trait RepositoryBase {
  def owner: String
  def shortName: String
  def id: String
}

case class Repository(name: String, usesIssueLinks: Boolean, accessToken: Option[String], _id: BSONObjectID = BSONObjectID.generate) extends RepositoryBase {
  def owner = name.split("/").head

  def shortName = name.split("/").last

  def id = _id.stringify
}

object Repository {

  implicit val repositoryFormat = Json.format[Repository]

  def publicRepositoryReads =
    ((__ \ 'name).read[String] and
      (__ \ 'usesIssueLinks).read[Boolean] and
      (__ \ 'accessToken).readNullable[String])(Repository(_,_,_))

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
}
