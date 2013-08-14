package controllers

import play.api.mvc.{Action}
import models._
import braingames.reactivemongo.GlobalDBAccess
import play.api.data.Form
import play.api.data.Forms._
import views.html
import play.api.libs.concurrent.Execution.Implicits._
import braingames.util.ExtendedTypes._
import scala.concurrent.Future
import braingames.reactivemongo.DBAccessContext
import play.api.libs.json.{JsObject, JsString, JsArray, Json}
import models.TimeEntry._
import play.api.libs.json.JsArray
import models.User
import play.api.libs.json.JsObject

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 13:21
 */
    /*
object DurationParser{
  val p = "(\\d+)d\\s+(\\d+)h\\s+(\\d+)m\\s+(\\d+)s"r

  /**
   * Parses a duration string of the form "98d 01h 23m 45s" into milliseconds.
   *
   * @throws ParseException
   */
  public static long parseDuration(String duration) throws ParseException {
    Matcher m = p.matcher(duration);

    long milliseconds = 0;

    if (m.find() && m.groupCount() == 4) {
      int days = Integer.parseInt(m.group(1));
      milliseconds += TimeUnit.MILLISECONDS.convert(days, TimeUnit.DAYS);
      int hours = Integer.parseInt(m.group(2));
      milliseconds += TimeUnit.MILLISECONDS
        .convert(hours, TimeUnit.HOURS);
      int minutes = Integer.parseInt(m.group(3));
      milliseconds += TimeUnit.MILLISECONDS.convert(minutes,
        TimeUnit.MINUTES);
      int seconds = Integer.parseInt(m.group(4));
      milliseconds += TimeUnit.MILLISECONDS.convert(seconds,
        TimeUnit.SECONDS);
    } else {
      throw new ParseException("Cannot parse duration " + duration, 0);
    }

    return milliseconds;
  }
}  */

object TimeEntryController extends Controller with GlobalDBAccess with securesocial.core.SecureSocial {
  val DefaultAccessRole = None

  def parseAsDuration(s: String) = {
    s
    Some(4)
  }

  def create(owner: String, repo: String, issueNumber: Int) = SecuredAction(ajaxCall = false, authorize = None, p = parse.urlFormEncoded) {
    implicit request =>
      Async {
        val fullName = RepositoryDAO.createFullName(owner, repo)
        val user = request.user.asInstanceOf[User]
        GithubApi.isCollaborator(user, user.githubAccessToken, fullName).map {
          case true =>
            (for {
              duration <- postParameter("duration").flatMap(parseAsDuration)
            } yield {
              val issue = Issue(fullName, issueNumber)
              val timeEntry = TimeEntry(issue, duration, "testUser")
              TimeEntryDAO.createTimeEntry(timeEntry)
              Ok
            }).getOrElse(BadRequest("no valid duration suplied"))
          case false =>
            BadRequest("Not allowed.")
        }
      }
  }

  def createForm(owner: String, repo: String, issueNumber: Int) = SecuredAction {
    implicit request =>
      Ok(html.timeEntry(owner, repo, issueNumber))
  }

  def showTimeForIssue(owner: String, repo: String, issueNumber: Int) = SecuredAction {
    implicit request =>
      Async {
        val fullName = RepositoryDAO.createFullName(owner, repo)
        TimeEntryDAO.loggedTimeForIssue(Issue(fullName, issueNumber)).map {
          entries =>
            val jsonUserTimesList = createUserTimesList(entries)

            Ok(JsObject(jsonUserTimesList))
        }
      }
  }

  def showTimeForAUser(user: String, year: Int, month: Int)(implicit ctx: DBAccessContext): Future[JsObject] = {
    TimeEntryDAO.loggedTimeForUser(user, year, month).map {
      entries =>
        val jsonProjectsTimesList =
          entries.groupBy(_.issue.project).map {
            case (project, entries) =>
              val jsonTimeEntries = entries.map(TimeEntryDAO.formatter.writes)
              project -> JsArray(jsonTimeEntries)
          }.toList

        Json.obj("user" -> user, "projects" -> JsObject(jsonProjectsTimesList))
    }
  }

  def showTimeForUser(year: Int, month: Int) = SecuredAction {
    implicit request =>
      Async {
        showTimeForAUser(request.user.id.id, year, month).map{ result =>
          Ok(result)
        }
      }
  }

  def createUserTimesList(entries: List[TimeEntry]) = {
    entries.groupBy(_.user).map {
      case (user, entries) =>
        val jsonTimeEntries = entries.map(TimeEntryDAO.formatter.writes)
        user -> JsArray(jsonTimeEntries)
    }.toList
  }

  def showTimesForInterval(year: Int, month: Int) = SecuredAction {
    implicit request =>
      Async {
        TimeEntryDAO.loggedTimeForInterval(year, month).map {
          entries =>
            val jsonUserTimesList = createUserTimesList(entries)

            Ok(JsObject(jsonUserTimesList))
        }
      }
  }
}
