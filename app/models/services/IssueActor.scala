package models.services

import akka.actor.Actor
import models.Repository
import controllers.GithubApi
import braingames.util.StartableActor
import controllers.GithubIssue
import play.api.Logger

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 25.07.13
 * Time: 02:23
 */
case class FullScan(repo: Repository)

class IssueActor extends Actor {
  implicit val ec = context.system.dispatcher

  def receive = {
    case FullScan(repo) =>
      Logger.debug("Starting repo full scan.")
      GithubApi.listRepositoryIssues(repo.accessToken, repo.fullName).map {
        issues =>
          issues.map {
            issue =>
              ensureTimeTrackingLink(repo, issue)
          }
      }
  }

  def timeTrackingLinkFor(repo: Repository, issue: GithubIssue) = {
    s"""<a href="http://localhost:9000${controllers.routes.TimeEntryController.createForm(repo.owner, repo.name, issue.number).url}" target="_blank">Log Time</a>"""
  }

  def ensureTimeTrackingLink(repo: Repository, issue: GithubIssue) = {
    if (!issue.body.contains(timeTrackingLinkFor(repo, issue))) {
      val body = issue.body + "\n" + timeTrackingLinkFor(repo, issue)
      GithubApi.updateIssueBody(repo.accessToken, issue, body)
    }
  }

}

object IssueActor extends StartableActor[IssueActor] {
  val name = "issueActor"
}
