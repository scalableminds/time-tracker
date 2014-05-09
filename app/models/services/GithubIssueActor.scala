package models.services

import akka.actor.Actor
import models.Repository
import controllers.{Application, GithubApi, GithubIssue}
import braingames.reactivemongo.{GlobalAccessContext, GlobalDBAccess, DBAccessContext}
import braingames.util.StartableActor
import play.api.Logger
import models.{IssueDAO, ArchivedIssue}
import scala.concurrent.Future

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 25.07.13
 * Time: 02:23
 */
case class FullScan(repo: Repository, accesssToken: String)

class GithubIssueActor extends Actor {
  implicit val ec = context.system.dispatcher

  def receive = {
    case FullScan(repo, accessToken) =>
      Logger.debug("Starting repo full scan.")
      GithubApi.listRepositoryIssues(accessToken, repo.name).map {
        issues =>
          issues.map {
            issue =>
              GithubIssueActor.ensureIssueIsArchived(repo, issue)
              GithubIssueActor.ensureTimeTrackingLink(repo, issue, accessToken)
          }
      }
  }

}

object GithubIssueActor extends StartableActor[GithubIssueActor] {
  val name = "githubIssueActor"

  val linkRx = "<a[^>]*>Log Time</a>"

  def timeTrackingLinkFor(repo: Repository, issue: GithubIssue) = {
    val link =
      Application.hostUrl + controllers.routes.TimeEntryController.createForm(repo.owner, repo.shortName, issue.number, Some("github")).url
    s"""<a href="$link" target="_blank">Log Time</a>"""
  }

  def containsLinkHeuristic(s: String) = linkRx.r.findFirstIn(s)

  def ensureTimeTrackingLink(repo: Repository, issue: GithubIssue, accessToken: String) = {
    val link = timeTrackingLinkFor(repo, issue)
    containsLinkHeuristic(issue.body) match {
      case Some(currentLink) if currentLink == link =>
        // there is nothing to do here
        Future.successful(true)
      case Some(currentLink) =>
        val body = issue.body.replaceAll(linkRx, link)
        GithubApi.updateIssueBody(accessToken, issue, body)
      case _ =>
        val body = issue.body + "\n\n" + link
        GithubApi.updateIssueBody(accessToken, issue, body)
    }
  }

  def ensureIssueIsArchived(repo: Repository, issue: GithubIssue) = {
    IssueDAO.archiveIssue(ArchivedIssue(repo.name, issue.number, issue.title))(GlobalAccessContext)
  }
}
