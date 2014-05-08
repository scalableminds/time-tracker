package controllers.admin

import controllers.{Application, Controller, GithubApi}
import models.{Repository, RepositoryDAO, User}
import play.api.libs.concurrent.Execution.Implicits._
import views.html
import scala.concurrent.Future
import braingames.reactivemongo.{GlobalAccessContext, GlobalDBAccess}
import play.api.libs.concurrent.Akka
import models.services.{FullScan, GithubIssueActor}
import play.api.Play.current
import play.api.libs.concurrent.Execution.Implicits._
import net.liftweb.common.{Full, Failure, Empty}

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 21.07.13
 * Time: 16:14
 */
object RepositoryAdministration extends Controller {
  lazy val issueActor = Akka.system.actorFor("/user/" + GithubIssueActor.name)

  def hookUrl(repositoryName: String) =
    s"${Application.hostUrl}/repos/$repositoryName/hook"

  def list = Authenticated.async {
    implicit request =>
      val user = request.user
      for {
        usedRepositories <- RepositoryDAO.findAll
      } yield {
        val available = user.adminRepositories.map(_.name).diff(usedRepositories.map(_.fullName))
        Ok(html.admin.repositoryAdmin(available, usedRepositories, request.user))
      }
  }

  def ensureAdminRights(user: User, repositoryName: String) = {
    user.namesOfAdminRepositories.contains(repositoryName) match {
      case true => Full(true)
      case _ => Failure("You are not allowed to access this repository")
    }
  }

  def add = Authenticated.async(parse.urlFormEncoded) {
    implicit request =>
      for {
        repositoryName <- postParameter("repository")(request.request) ?~> "No repository name supplied"
        _ <- ensureAdminRights(request.user, repositoryName).toFox
        r <- RepositoryDAO.findByName(repositoryName).futureBox
      } yield {
        r match {
          case Empty =>
            val repo = Repository(repositoryName)
            RepositoryDAO.insert(repo)
            GithubApi.createWebHook(request.user.githubAccessToken, repositoryName, hookUrl(repositoryName))
            issueActor ! FullScan(repo, request.user.githubAccessToken)
            Redirect(controllers.admin.routes.RepositoryAdministration.list)
          case _ =>
            BadRequest("Repository allready added")
        }
      }
  }

  def delete(owner: String, name: String) = Authenticated.async {
    implicit request =>
      val repositoryName = Repository.createFullName(owner, name)
      for {
        repository <- RepositoryDAO.findByName(repositoryName) ?~> "Repository not found"
        _ <- ensureAdminRights(request.user, repository.fullName)
      } yield {
        RepositoryDAO.removeByName(repository.fullName)
        JsonOk("Repository deleted")
      }
  }

  def scan(owner: String, name: String) = Authenticated.async {
    implicit request =>
      val repositoryName = Repository.createFullName(owner, name)
      for {
        repository <- RepositoryDAO.findByName(repositoryName) ?~> "Repository not found"
        _ <- ensureAdminRights(request.user, repository.fullName)
      } yield {
        issueActor ! FullScan(repository, request.user.githubAccessToken)
        JsonOk("Scan is in progress")
      }
  }
}
