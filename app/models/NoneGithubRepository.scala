/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package models

import com.scalableminds.util.reactivemongo.{DefaultAccessDefinitions, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import com.scalableminds.util.reactivemongo.AccessRestrictions._
import reactivemongo.bson.BSONObjectID
import models.auth.UserService
import com.scalableminds.util.tools.Fox
import scala.concurrent.Future
import play.modules.reactivemongo.json.BSONFormats._
import play.api.libs.json._
import play.api.libs.functional.syntax._

case class NoneGithubRepository(name: String, admins: List[String], users: List[String], _id: BSONObjectID = BSONObjectID.generate) extends RepositoryBase {
  def owner = name.split("/").head
  def shortName = name.split("/").last
  def id = _id.stringify
}

object NoneGithubRepository {

  implicit val repositoryFormat = Json.format[NoneGithubRepository]

  def publicRepositoryReads =
    ((__ \ "name").read[String] and
    (__ \ "admins").read[List[String]] and
    (__ \ "users").read[List[String]])(NoneGithubRepository(_,_,_))

  def publicRepositoryWrites(repository: NoneGithubRepository): Future[JsObject] = {
    Future.successful(Json.obj(
      "name" -> repository.name,
      "admins" -> repository.admins,
      "users" -> repository.users,
      "id" -> repository.id
    ))
  }

  def createFullName(owner: String, repo: String) =
    owner + "/" + repo
}

object NoneGithubRepositoryDAO extends BasicReactiveDAO[NoneGithubRepository] {
  val collectionName = "repositories.none.github"

  implicit val formatter = NoneGithubRepository.repositoryFormat

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

  def findAll(user: User)(implicit ctx: DBAccessContext) = {
    find(Json.obj("admins" -> user.profile.fullName)).cursor[NoneGithubRepository].collect[List]()
    // find(Json.obj("name" -> user.profile.fullName)).cursor[NoneGithubRepository].collect[List]()
  }

}
