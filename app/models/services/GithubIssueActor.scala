package models.services

import akka.actor.Actor
import models.Repository
import controllers.{Application, GithubApi, GithubIssue}
import braingames.util.StartableActor
import play.api.Logger

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 25.07.13
 * Time: 02:23
 */
case class FullScan(repo: Repository)

class GithubIssueActor extends Actor {
  implicit val ec = context.system.dispatcher

  def receive = {
    case FullScan(repo) =>
      Logger.debug("Starting repo full scan.")
      GithubApi.listRepositoryIssues(repo.accessToken, repo.fullName).map {
        issues =>
          issues.map {
            issue =>
              GithubIssueActor.ensureTimeTrackingLink(repo, issue)
          }
      }
  }

}

object GithubIssueActor extends StartableActor[GithubIssueActor] {
  val name = "githubIssueActor"

  def timeTrackingLinkFor(repo: Repository, issue: GithubIssue) = {
    val link =
      Application.hostUrl + controllers.routes.TimeEntryController.createForm(repo.owner, repo.name, issue.number).url
    s"""<a href="$link" target="_blank">Log Time</a>"""
  }

  def ensureTimeTrackingLink(repo: Repository, issue: GithubIssue) = {
    val link = timeTrackingLinkFor(repo, issue)
    if (!issue.body.contains(link)) {
      val body = issue.body + "\n\n" + link
      GithubApi.updateIssueBody(repo.accessToken, issue, body)
    }
  }
}
