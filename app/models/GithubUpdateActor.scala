/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package models

import akka.actor.Actor
import com.scalableminds.util.auth.AccessToken
import controllers.Application
import com.scalableminds.util.reactivemongo.{GlobalAccessContext, DBAccessContext}
import com.scalableminds.util.tools.{FoxImplicits, StartableActor}
import models.GithubUpdateActor
import models.auth.UserService
import play.api.{Play, Logger}
import scala.concurrent.Future
import com.scalableminds.util.github.GithubApi
import com.scalableminds.util.github.models.GithubIssue
import scala.concurrent.duration._

case class FullScan(repo: Repository, accesssToken: String)
case class UpdateAUsersRepositories(user: User, token: AccessToken)
case object UpdateAllUserRepositories

class GithubUpdateActor extends Actor {
  implicit val ec = context.system.dispatcher

  val conf = Play.current.configuration

  val userRepositoryUpdateInterval =
    (conf.getInt("application.github.userRepositoryUpdateIntervalInMinutes") getOrElse 5) minutes

  override def preStart = {
    context.system.scheduler.schedule(userRepositoryUpdateInterval, userRepositoryUpdateInterval, self, UpdateAllUserRepositories)
  }

  def receive = {
    case UpdateAUsersRepositories(user, token) =>
      GithubUpdateActor.updateUserRepositories(user, token)

    case UpdateAllUserRepositories =>
      UserDAO.findAll(GlobalAccessContext).map( users =>
        users.map( user => self ! UpdateAUsersRepositories(user, user.authInfo)))

    case FullScan(repo, accessToken) =>
      Logger.debug("Starting repo full scan.")
      GithubApi.listRepositoryIssues(accessToken, repo.name).foreach {
        issues =>
          issues.foreach {
            issue =>
              GithubUpdateActor.ensureIssue(repo, issue, accessToken)
          }
      }
  }

}

object GithubUpdateActor extends StartableActor[GithubUpdateActor] with FoxImplicits{
  import play.api.libs.concurrent.Execution.Implicits._

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

  def updateUserRepositories(user: User, token: AccessToken) = {
    GithubApi.listAllUserRepositories(token.accessToken).toFox.flatMap{ repositories =>
      val rs = repositories.map(r => RepositoryAccess(r.full_name, r.permissions.admin, r.permissions.push))
      UserService.updateRepositories(user.userId, rs)(GlobalAccessContext)
    }
  }

  def ensureIssueIsArchived(repo: Repository, issue: GithubIssue) = {
    IssueDAO.archiveIssue(Issue(IssueReference(repo.name, issue.number), issue.title))(GlobalAccessContext)
  }
}
