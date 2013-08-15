package controllers.admin

import controllers.Controller
import securesocial.core.SecureSocial
import controllers.GithubApi
import models.{Repository, RepositoryDAO, User}
import play.api.libs.concurrent.Execution.Implicits._
import views.html
import scala.concurrent.Future
import braingames.reactivemongo.GlobalDBAccess
import play.api.libs.concurrent.Akka
import models.services.{FullScan, GithubIssueActor}
import play.api.Play.current
import play.api.libs.concurrent.Execution.Implicits._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 21.07.13
 * Time: 16:14
 */
object RepositoryAdministration extends Controller with SecureSocial with GlobalDBAccess {
  lazy val issueActor = Akka.system.actorFor("/user/" + GithubIssueActor.name)

  def list = SecuredAction {
    implicit request =>
      Async {
        val user = request.user.asInstanceOf[User]
        for {
          orgas <- GithubApi.listOrgs(user.githubAccessToken)
          orgaRepos <- Future.traverse(orgas)(orga => GithubApi.listOrgaRepositories(user.githubAccessToken, orga))
          userRepos <- GithubApi.listUserRepositories(user.githubAccessToken)
          usedRepos <- RepositoryDAO.findAll
        } yield {
          val available = (orgaRepos.flatten ::: userRepos).diff(usedRepos.map(_.fullName))
          Ok(html.admin.repositoryAdmin(available, usedRepos))
        }
      }
  }

  def add = SecuredAction(ajaxCall = false, authorize = None, p = parse.urlFormEncoded) {
    implicit request =>
      Async {
        val user = request.user.asInstanceOf[User]
        for {
          repositoryName <- postParameter("repository")(request.request) ?~> "No repository name supplied"
          accessToken <- postParameter("accessToken")(request.request) ?~> "No access token supplied"
          r <- RepositoryDAO.findByName(repositoryName)
        } yield {
          if (r.isEmpty) {
            val repo = Repository(repositoryName, accessToken, List(user.githubId), List(user.githubId))
            RepositoryDAO.insert(repo)
            GithubApi.createWebHook(user.githubAccessToken, repositoryName, "http://localhost:9000/repositories")
            issueActor ! FullScan(repo)
            Redirect(controllers.admin.routes.RepositoryAdministration.list)
          } else
            BadRequest("Repository allready added")
        }
      }
  }

  def delete(owner: String, name: String) = SecuredAction {
    implicit request =>
      Async {
        val user = request.user.asInstanceOf[User]
        val repositoryName = RepositoryDAO.createFullName(owner, name)
        for {
          repository <- RepositoryDAO.findByName(repositoryName) ?~> "Repository not found"
        } yield {
          if (repository.isAdmin(user)) {
            RepositoryDAO.removeByName(repository.fullName)
            JsonOk("Repository deleted")
          } else {
            JsonBadRequest("You are not allowed to delete the repository")
          }
        }
      }
  }

  def scan(owner: String, name: String) = SecuredAction {
    implicit request =>
      Async {
        val repositoryName = RepositoryDAO.createFullName(owner, name)
        for {
          repository <- RepositoryDAO.findByName(repositoryName) ?~> "Repository not found"
        } yield {
          issueActor ! FullScan(repository)
          JsonOk("Scan is in progress")
        }
      }
  }
}
