package models

import play.api.libs.json.{JsString, JsArray, Json}
import braingames.reactivemongo.DBAccessContext
import play.api.libs.concurrent.Execution.Implicits._
import java.util.{Calendar, Date}
import org.joda.time.{Interval, YearMonth}
import play.api.Logger
import scala.concurrent.Await
import scala.concurrent.duration._
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

case class TimeEntry(issue: Issue, duration: Int, userGID: String, comment: Option[String], timestamp: Long = System.currentTimeMillis)

object TimeEntry extends{
  def fromForm(issue: Issue, duration: Int, userGID: String, comment: Option[String]) =
    TimeEntry(issue, duration, userGID, comment)

  def toForm(t: TimeEntry) =
    Some((t.issue, t.duration, t.userGID, t.comment))
}

object TimeEntryDAO extends BasicReactiveDAO[TimeEntry] {
  val collectionName = "timeEntries"

  import Issue.issueFormatter

  override def findQueryFilter(implicit ctx: DBAccessContext) = {
    ctx.data match {
      case _ if(ctx.globalAccess) =>
        AllowEveryone
      case Some(user: User) =>
        val repositories = Await.result(RepositoryDAO.findAllWhereUserIsAdmin(user), 5 seconds)
        AllowIf(Json.obj("$or" -> Json.arr(
          Json.obj("issue.project" -> Json.obj("$in" -> JsArray(repositories.map(r => JsString(r.fullName))))),
          Json.obj("userGID" -> user.githubId)
        )))
    }
  }

  val formatter = Json.format[TimeEntry]

  def createTimeEntry(timeEntry: TimeEntry)(implicit ctx: DBAccessContext) = {
    insert(timeEntry)
  }

  def loggedTimeForIssue(issue: Issue)(implicit ctx: DBAccessContext) = {
    find(Json.obj("issue" -> issue)).collect[List]()
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
      Json.obj("userGID" -> userGID) ++ timeStampQuery(interval)).collect[List]()
  }

  def loggedTimeForInterval(year: Int, month: Int)(implicit ctx: DBAccessContext) = {
    val interval = toInterval(year, month)
    find(timeStampQuery(interval)).collect[List]()
  }
}
