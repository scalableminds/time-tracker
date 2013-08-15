package controllers

import play.api.mvc.Action
import java.io.File
import scala.reflect.io.Path
import play.api.Logger
import models.services.GithubIssueActor
import models.RepositoryDAO
import GithubApi.githubIssueFormat
import braingames.reactivemongo.GlobalAccessContext
import play.api.libs.concurrent.Execution.Implicits._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 15.08.13
 * Time: 23:54
 */
object RepositoryController extends Controller {

  def issueHook(owner: String, repository: String) = Action(parse.json) {
    implicit request =>
      for {
        action <- (request.body \ "action").asOpt[String]
        if action == "opened"
        issue <- (request.body \ "issue").asOpt[GithubIssue]
      } {
        RepositoryDAO.findByName(RepositoryDAO.createFullName(owner, repository))(GlobalAccessContext).map {
          case Some(repo) =>
            GithubIssueActor.ensureTimeTrackingLink(repo, issue)
          case _ =>
            Logger.warn(s"Issue hook triggered, but couldn't find repository $owner/$repository")
        }
      }
      Logger.debug("Got payload: " + request.body)
      Ok("Thanks octocat :)")
  }
}
