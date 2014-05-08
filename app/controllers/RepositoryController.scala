package controllers

import play.api.mvc.Action
import play.api.Logger
import models.services.GithubIssueActor
import models.{Repository, RepositoryDAO}
import GithubApi.githubIssueFormat
import braingames.reactivemongo.GlobalAccessContext
import play.api.libs.concurrent.Execution.Implicits._
import net.liftweb.common.Full
import models.auth.UserService
import scala.concurrent.Future
import play.api.libs.json.Json

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 15.08.13
 * Time: 23:54
 */
object RepositoryController extends Controller {

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

  def issueHook(owner: String, repository: String) = Action(parse.json) {
    implicit request =>
      for {
        action <- (request.body \ "action").asOpt[String]
        if action == "opened"
        issue <- (request.body \ "issue").asOpt[GithubIssue]
      } {
        RepositoryDAO.findByName(Repository.createFullName(owner, repository))(GlobalAccessContext).futureBox.foreach {
          case Full(repo) =>
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
          case _ =>
            Logger.warn(s"Issue hook triggered, but couldn't find repository $owner/$repository")
        }
      }
      Ok("Thanks octocat :)")
  }
}
