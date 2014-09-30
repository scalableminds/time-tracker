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

  def publicRepoWrites(repoFox: Fox[NoneGithubRepository]): Future[JsObject] = {
    val repo = for {
      repository <- repoFox
    } yield {
      Json.obj(
        "name" -> repository.name,
        "admins" -> repository.admins,
        "users" -> repository.users,
        "id" -> repository.id
      )
    }

    Fox.sequenceOfFulls(List(repo)).map { _.head }
  }

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

case class NoneGithubRepo(name: String, _id: BSONObjectID)
object NoneGithubRepo {
  implicit val formatter = Json.format[NoneGithubRepo]
}

object NoneGithubRepoDAO extends BasicReactiveDAO[NoneGithubRepo] {
  val collectionName = "repositories.none.github"
  implicit val formatter = NoneGithubRepo.formatter

  def findOneByID(id: BSONObjectID)(implicit ctx: DBAccessContext) = {
    find(Json.obj("_id" -> id))
  }

  // todo - remove get
  def makeRepos(repos: List[NoneGithubRepo])(implicit ctx: DBAccessContext) = {
    val repositories = repos map { repo =>
      for {
        usersRepo <- NoneGithubRepoUserDAO.findByRepoId(repo._id.stringify)
        adminsRepo <- NoneGithubRepoUserDAO.findByRepoId(repo._id.stringify, isAdmin = true)
        usersId <- Future.successful(usersRepo.map(_.userId))
        adminsId <- Future.successful(adminsRepo.map(_.userId))
        users <- Future.traverse(usersId)(UserService.find(_).futureBox)
        admins <- Future.traverse(adminsId)(UserService.find(_).futureBox)
        usersFullNames <- Future.successful(users.map(_.get.profile.fullName))
        adminsFullNames <- Future.successful(users.map(_.get.profile.fullName))
      } yield {
        NoneGithubRepository(repo.name, adminsFullNames, usersFullNames, repo._id)
      }
    }
    Future.successful(repositories)
  }

}

case class NoneGithubRepoUser(repoId: String, userId: Int, isAdmin: Boolean)
object NoneGithubRepoUser {
  implicit val formatter = Json.format[NoneGithubRepoUser]
}
object NoneGithubRepoUserDAO extends BasicReactiveDAO[NoneGithubRepoUser] {
  val collectionName = "repositories.none.github.users"
  implicit val formatter = NoneGithubRepoUser.formatter

  def findByRepoId(repoId: String, isAdmin: Boolean = false)(implicit ctx: DBAccessContext) = {
    find(Json.obj("repoId" -> repoId, "isAdmin" -> isAdmin)).cursor[NoneGithubRepoUser].collect[List]()
  }

  def findAll(user: User, isAdmin: Boolean = false)(implicit ctx: DBAccessContext) = {
    find(Json.obj("userId" -> user.userId, "isAdmin" -> isAdmin)).cursor[NoneGithubRepoUser].collect[List]()
  }

}


