package models

import play.api.libs.json.Json
import braingames.reactivemongo.DBAccessContext
import play.api.libs.concurrent.Execution.Implicits._
import java.util.{Calendar, Date}
import org.joda.time.{Interval, YearMonth}
import play.api.Logger

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 13:15
 */
case class Issue(project: String, number: Int)

object Issue extends Function2[String, Int, Issue] {
  implicit val issueFormatter = Json.format[Issue]
}

case class TimeEntry(issue: Issue, duration: Int, userGID: String, timestamp: Long = System.currentTimeMillis)

object TimeEntry extends Function4[Issue, Int, String, Long, TimeEntry]{
  def fromForm(issue: Issue, duration: Int, userGID: String) =
    TimeEntry(issue, duration, userGID)

  def toForm(t: TimeEntry) =
    Some((t.issue, t.duration, t.userGID))
}

object TimeEntryDAO extends BasicReactiveDAO[TimeEntry] {
  val collectionName = "timeEntries"

  import Issue.issueFormatter

  val formatter = Json.format[TimeEntry]

  def createTimeEntry(timeEntry: TimeEntry)(implicit ctx: DBAccessContext) = {
    insert(timeEntry)
  }

  def loggedTimeForIssue(issue: Issue)(implicit ctx: DBAccessContext) = {
    find(Json.obj("issue" -> issue)).toList
  }

  def toInterval(year: Int, month: Int) = {
    new YearMonth(year, month).toInterval
  }

  def timeStampQuery(interval: Interval) = {
    Json.obj(
      "timestamp" -> Json.obj(
        "$gte" -> interval.getStart.getMillis,
        "$lte" -> interval.getEnd.getMillis
      )
    )
  }

  def loggedTimeForUser(userGID: String, year: Int, month: Int)(implicit ctx: DBAccessContext) = {
    val interval = toInterval(year, month)
    find(
      Json.obj("userGID" -> userGID) ++ timeStampQuery(interval)).toList
  }

  def loggedTimeForInterval(year: Int, month: Int)(implicit ctx: DBAccessContext) = {
    val interval = toInterval(year, month)
    find(timeStampQuery(interval)).toList
  }
}
