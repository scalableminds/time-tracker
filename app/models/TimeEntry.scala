/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models

import play.api.libs.json.{JsString, JsArray, Json}
import com.scalableminds.util.reactivemongo.{DefaultAccessDefinitions, DBAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import org.joda.time.{DateTime, Interval, YearMonth}
import scala.concurrent.Await
import scala.concurrent.duration._
import com.scalableminds.util.reactivemongo.AccessRestrictions._

case class TimeEntry(
  issueReference: IssueReference,
  duration: Int,
  userId: Int,
  comment: Option[String],
  dateTime: DateTime = DateTime.now())

object TimeEntry extends {

  implicit val timeEntryFormatter = Json.format[TimeEntry]

  def fromForm(issue: IssueReference, duration: Int, userId: Int, comment: Option[String]) =
    TimeEntry(issue, duration, userId, comment)

  def toForm(t: TimeEntry) =
    Some((t.issueReference, t.duration, t.userId, t.comment))

  def publicTimeEntryWrites(timeEntry: TimeEntry, issueResolver: Map[IssueReference, Issue]) = {
    val issue =
      issueResolver.getOrElse(timeEntry.issueReference, Issue(timeEntry.issueReference, "", None))

    Json.obj(
      "duration" -> timeEntry.duration,
      "userId" -> timeEntry.userId,
      "comment" -> timeEntry.comment,
      "dateTime" -> timeEntry.dateTime,
      "issue" -> issue
    )
  }
}

object TimeEntryDAO extends BasicReactiveDAO[TimeEntry] {
  val collectionName = "timeEntries"

  implicit val formatter = TimeEntry.timeEntryFormatter

  override val AccessDefinitions = new DefaultAccessDefinitions {
    override def findQueryFilter(implicit ctx: DBAccessContext) = {
      ctx.data match {
        case Some(user: User) =>
          AllowIf(Json.obj("$or" -> Json.arr(
            Json.obj("issueReference.project" -> Json.obj("$in" -> user.namesOfAdminRepositories)),
            Json.obj("userId" -> user.userId)
          )))
        case _ =>
          DenyEveryone()
      }
    }
  }

  def createTimeEntry(timeEntry: TimeEntry)(implicit ctx: DBAccessContext) = {
    insert(timeEntry)
  }

  def loggedTimeForIssue(issueReference: IssueReference)(implicit ctx: DBAccessContext) = {
    find(Json.obj("issueReference" -> issueReference)).cursor[TimeEntry].collect[List]()
  }

  def toInterval(year: Int, month: Int) = {
    new YearMonth(year, month).toInterval
  }

  def timeStampQuery(interval: Interval) = {
    Json.obj(
      "dateTime" -> Json.obj(
        "$gte" -> interval.getStart.getMillis,
        "$lt" -> interval.getEnd.getMillis
      )
    )
  }

  def loggedTimeForUser(userId: Int, year: Int, month: Int)(implicit ctx: DBAccessContext) = withExceptionCatcher {
    val interval = toInterval(year, month)
    find(
      Json.obj("userId" -> userId) ++ timeStampQuery(interval)).cursor[TimeEntry].collect[List]()
  }

  def loggedTimeForInterval(year: Int, month: Int)(implicit ctx: DBAccessContext) = {
    val interval = toInterval(year, month)
    find(timeStampQuery(interval)).cursor[TimeEntry].collect[List]()
  }
}
