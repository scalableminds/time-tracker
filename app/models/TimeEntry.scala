package models

import play.api.libs.json.Json
import braingames.reactivemongo.DBAccessContext
import play.api.libs.concurrent.Execution.Implicits._

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

case class TimeEntry(issue: Issue, duration: Int, user: String, timestamp: Long = System.currentTimeMillis)

object TimeEntry extends Function4[Issue, Int, String, Long, TimeEntry]{
  def fromForm(issue: Issue, duration: Int, user: String) =
    TimeEntry(issue, duration, user)

  def toForm(t: TimeEntry) =
    Some((t.issue, t.duration, t.user))
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

  def loggedTimeForUser(user: String)(implicit ctx: DBAccessContext) = {
    find(Json.obj("user" -> user)).toList
  }
}
