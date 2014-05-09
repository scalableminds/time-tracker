package controllers

import play.api.mvc.Action
import play.api.Logger
import models.services.{FullScan, GithubIssueActor}
import models.{User, Repository, RepositoryDAO}
import GithubApi.githubIssueFormat
import braingames.reactivemongo.GlobalAccessContext
import play.api.libs.concurrent.Execution.Implicits._
import net.liftweb.common.{Failure, Empty, Full}
import models.auth.UserService
import scala.concurrent.Future
import play.api.libs.json.{JsError, JsSuccess, Json}
import play.api.libs.concurrent.Akka
import play.api.Play.current
/**
 * Company: scalableminds
 * User: tmbo
 * Date: 15.08.13
 * Time: 23:54
 */
object RepositoryController extends Controller {

  lazy val issueActor = Akka.system.actorFor("/user/" + GithubIssueActor.name)

  def hookUrl(repositoryName: String) =
    s"${Application.hostUrl}/api/repos/$repositoryName/hook"

  def tryWithAnyAccessToken[T](tokens: List[String], body: String => Future[Boolean]) = {
    def tryNext(tokens: List[String]): Future[Boolean] = {
      tokens match {
        case token :: tail =>
          body(token).flatMap {
            case true => Future.successful(true)
            case false => tryNext(tail)
          }
        case _ =>
          Future.successful(false)
      }
    }
    tryNext(tokens)
  }

  def list = Authenticated.async{ implicit request =>
    for{
      repositories <- RepositoryDAO.findAll
    } yield Ok(Json.toJson(repositories))
  }

  def ensureAdminRights(user: User, repositoryName: String) = {
    user.namesOfAdminRepositories.contains(repositoryName) match {
      case true => Full(true)
      case _ => Failure("You are not allowed to access this repository")
    }
  }

  def add = Authenticated.async(parse.json) {
    implicit request =>
      request.body.validate(Repository.repositoryFormat) match {
        case JsSuccess(repo, _) =>
          if (repo.usesIssueLinks && repo.accessToken.isEmpty) {
            Future.successful(JsonBadRequest("repo.accessToken.missing"))
          } else {
            for {
              _ <- ensureAdminRights(request.user, repo.name).toFox
              r <- RepositoryDAO.findByName(repo.name).futureBox
            } yield {
              r match {
                case Empty =>
                  RepositoryDAO.insert(repo)
                  if (repo.usesIssueLinks) {
                    GithubApi.createWebHook(request.user.githubAccessToken, repo.name, hookUrl(repo.name))
                    issueActor ! FullScan(repo, request.user.githubAccessToken)
                  }
                  Redirect("/api/repos")
                case _ =>
                  BadRequest("Repository allready added")
              }
            }
          }
        case e: JsError =>
          Future.successful(BadRequest(JsError.toFlatJson(e)))
      }
  }

  def delete(owner: String, name: String) = Authenticated.async {
    implicit request =>
      val repositoryName = Repository.createFullName(owner, name)
      for {
        repository <- RepositoryDAO.findByName(repositoryName) ?~> "Repository not found"
        _ <- ensureAdminRights(request.user, repository.name)
      } yield {
        RepositoryDAO.removeByName(repository.name)
        JsonOk("Repository deleted")
      }
  }

  def scan(owner: String, name: String) = Authenticated.async {
    implicit request =>
      val repositoryName = Repository.createFullName(owner, name)
      for {
        repository <- RepositoryDAO.findByName(repositoryName) ?~> "Repository not found"
        _ <- ensureAdminRights(request.user, repository.name)
      } yield {
        if(repository.usesIssueLinks) {
          issueActor ! FullScan(repository, request.user.githubAccessToken)
          JsonOk("Scan is in progress")
        } else {
          JsonBadRequest("Issue links are disabled for this repository.")
        }
      }
  }

  def issueHook(owner: String, repository: String) = Action(parse.json) {
    implicit request =>
      for {
        action <- (request.body \ "action").asOpt[String]
        if action == "opened"
        issue <- (request.body \ "issue").asOpt[GithubIssue]
      } {
        RepositoryDAO.findByName(Repository.createFullName(owner, repository))(GlobalAccessContext).futureBox.foreach {
          case Full(repo) if repo.usesIssueLinks =>
            GithubIssueActor.ensureIssueIsArchived(repo, issue)
            val result = UserService.findAdminsOf(repo).map(_.map(_.githubAccessToken)).flatMap { tokens =>
              tryWithAnyAccessToken(tokens, GithubIssueActor.ensureTimeTrackingLink(repo, issue, _))
            }
            result.futureBox.map{
              case Full(true) =>
                Logger.info("Successfuly added link to issue with user token")
              case e =>
                Logger.warn("Failed to add link to issue with user token. " + e)
            }
          case Full(repo) =>
            Logger.warn(s"Issue hook triggered, for a repository with disabled issue links. ${repo.name}")
          case _ =>
            Logger.warn(s"Issue hook triggered, but couldn't find repository ${Repository.createFullName(owner,repository)}")
        }
      }
      Ok("Thanks octocat :)")
  }
}
