/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package controllers

import models._
import braingames.reactivemongo.{GlobalAccessContext, DBAccessContext}
import views.html
import play.api.libs.concurrent.Execution.Implicits._
import braingames.util.ExtendedTypes._
import scala.concurrent.Future
import models.User
import braingames.util.Fox
import play.api.Logger
import controllers.auth.UserAwareRequest
import net.liftweb.common.Failure
import org.joda.time.{LocalDateTime, DateTime}
import play.api.libs.json._
import net.liftweb.common.Full
import org.joda.time.format.ISODateTimeFormat

object TimeEntryController extends Controller {
  val DefaultAccessRole = None

  case class TimeEntryPost(duration: String, comment: Option[String], dateTime: DateTime)

  implicit val jodaDateReads: Reads[DateTime] =
    Reads.StringReads.map(x => LocalDateTime.parse(x, ISODateTimeFormat.dateTimeParser()).toDateTime)

  implicit val timeEntryPostFormat = Json.format[TimeEntryPost]

  def parseAsDuration(s: String) = {
    DurationParser.parse(s)
  }

  def userFromRequestOrKey(accessKey: String)(implicit request: UserAwareRequest[_]) = {
    for {
      u1 <- Future.successful(request.userOpt)
      u2 <- UserDAO.findByAccessKey(accessKey)(GlobalAccessContext).futureBox
    } yield {
      u1 orElse u2
    }
  }

  def ensureCollaboration(user: User, repository: Repository) = {
    user.isCollaboratorOf(repository) match {
      case true => Full(true)
      case _ => Failure("Not allowed")
    }
  }

  def create(id: String, issueNumber: Int, accessKey: String) = UserAwareAction.async(parse.json) {
    implicit request =>
      for {
        user <- userFromRequestOrKey(accessKey) ?~> "Unauthorized."
        repository <- RepositoryDAO.findOneById(id)(user) ?~> "Repository couldn't be found"
        _ <- ensureCollaboration(user, repository).toFox
        timeEntryPost <- request.body.asOpt[TimeEntryPost] ?~> "Invalid time entry supplied."
        duration <- parseAsDuration(timeEntryPost.duration) ?~> "Invalid duration supplied."
      } yield {
        val issueReference = IssueReference(repository.name, issueNumber)
        val timeEntry = TimeEntry(issueReference, duration, user.userId, timeEntryPost.comment, timeEntryPost.dateTime)
        TimeEntryDAO.createTimeEntry(timeEntry)(user)
        JsonOk("OK")
      }
  }

  def createGenericForm() = Authenticated.async {
    implicit request =>
      for {
        usedRepositories <- RepositoryDAO.findAll
      } yield {
        Ok(html.genericTimeEntry(usedRepositories))
      }
  }

  def createForm(id: String, issueNumber: Int, referer: Option[String]) = Authenticated.async {
    implicit request =>
      for {
        repository <- RepositoryDAO.findOneById(id) ?~> "Repository couldn't be found"
        _ <- ensureCollaboration(request.user, repository).toFox
      } yield {
        Ok(html.timeEntry(repository, issueNumber))
      }
  }

  def showTimeForIssue(id: String, issueNumber: Int) = Authenticated.async {
    implicit request =>
      for {
        repository <- RepositoryDAO.findOneById(id) ?~> "Repository couldn't be found"
        entries <- TimeEntryDAO.loggedTimeForIssue(IssueReference(repository.name, issueNumber))
      } yield {
        Ok(Json.toJson(entries))
      }
  }

  def userInfo(user: User) =
    Json.obj(
      "userId" -> user.userId,
      "name" -> user.profile.fullName,
      "email" -> user.profile.email)

  def showTimeForAUser(userId: Int, year: Int, month: Int)(implicit ctx: DBAccessContext): Fox[JsValue] = {
    import scala.collection.breakOut
    for {
      user <- UserDAO.findOneByUserId(userId) ?~> "User not found"
      entries <- TimeEntryDAO.loggedTimeForUser(userId, year, month)
      issueReferences = entries.map(_.issueReference)
      issues <- IssueDAO.findByIssueReferences(issueReferences)
    } yield {
      val issueMap: Map[IssueReference, Issue] =  issues.map(i => (i.reference, i))(breakOut)
      JsArray(entries.map(TimeEntry.publicTimeEntryWrites(_, issueMap)))
    }
  }

  def showTimeForUser(year: Int, month: Int) = Authenticated.async {
    implicit request =>
      for {
        times <- showTimeForAUser(request.user.userId, year, month)
      } yield {
        Ok(times)
      }
  }

  def createUserTimesList(entries: List[TimeEntry])(implicit ctx: DBAccessContext) = {
    import scala.collection.breakOut
    val l: List[Fox[JsObject]] = entries.groupBy(_.userId).map {
      case (userId, entries) =>
        UserDAO.findOneByUserId(userId).map { user =>
          val jsonTimeEntries = entries.map(TimeEntryDAO.formatter.writes)
          userInfo(user) ++ Json.obj("times" -> jsonTimeEntries)
        }
    }(breakOut)
    Fox.sequenceOfFulls(l).map(_.toSeq)
  }

  def showTimesForInterval(year: Int, month: Int) = Authenticated.async {
    implicit request =>
      for {
        entries <- TimeEntryDAO.loggedTimeForInterval(year, month)
      } yield {
        Ok(Json.toJson(entries))
      }
  }
}
