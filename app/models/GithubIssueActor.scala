/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package models

import akka.actor.Actor
import controllers.Application
import com.scalableminds.util.reactivemongo.{GlobalAccessContext, DBAccessContext}
import com.scalableminds.util.tools.StartableActor
import play.api.Logger
import scala.concurrent.Future
import com.scalableminds.util.github.GithubApi
import com.scalableminds.util.github.models.GithubIssue

case class FullScan(repo: Repository, accesssToken: String)

class GithubIssueActor extends Actor {
  implicit val ec = context.system.dispatcher

  def receive = {
    case FullScan(repo, accessToken) =>
      Logger.debug("Starting repo full scan.")
      GithubApi.listRepositoryIssues(accessToken, repo.name).foreach {
        issues =>
          issues.foreach {
            issue =>
              GithubIssueActor.ensureIssue(repo, issue, accessToken)
          }
      }
  }

}

object GithubIssueActor extends StartableActor[GithubIssueActor] {
  val name = "githubIssueActor"

  val linkRx = "<a[^>]*>Log Time</a>"

  def timeTrackingLinkFor(repo: Repository, issue: GithubIssue) = {
    val link =
      Application.hostUrl + s"/repos/${repo.id}/issues/${issue.number}/create?referer=github"
    s"""<a href="$link" target="_blank">Log Time</a>"""
  }

  def containsLinkHeuristic(s: String) = linkRx.r.findFirstIn(s)

  def ensureIssue(repo: Repository, issue: GithubIssue, accessToken: String) = {
    if(repo.usesIssueLinks)
      ensureTimeTrackingLink(repo, issue, accessToken)
    ensureIssueIsArchived(repo, issue)
  }

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
    IssueDAO.archiveIssue(Issue(IssueReference(repo.name, issue.number), issue.title))(GlobalAccessContext)
  }
}
