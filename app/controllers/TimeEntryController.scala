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
import braingames.mvc.Fox
import play.api.Logger

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 13:21
 */

object DurationParser {
  val durationRx = """^\s*(?:(\d+)\s*d)?\s*(?:(\d+)\s*h)?\s*(?:(\d+)\s*m)?\s*$""" r

  def parse(s: String) = {
    durationRx.findFirstMatchIn(s).map {
      case durationRx(_d, _h, _m) =>
        val d = if (_d == null) 0 else _d.toInt
        val h = if (_h == null) 0 else _h.toInt
        val m = if (_m == null) 0 else _m.toInt

        (d * 8 + h) * 60 + m
    }
  }
}

object TimeEntryController extends Controller with GlobalDBAccess with securesocial.core.SecureSocial {
  val DefaultAccessRole = None

  def parseAsDuration(s: String) = {
    DurationParser.parse(s)
  }

  def create(owner: String, repo: String, issueNumber: Int) = SecuredAction(ajaxCall = false, authorize = None, p = parse.urlFormEncoded) {
    implicit request =>
      Async {
        val fullName = RepositoryDAO.createFullName(owner, repo)
        val user = request.user.asInstanceOf[User]
        GithubApi.isCollaborator(user, user.githubAccessToken, fullName).map {
          case true =>
            for {
              duration <- postParameter("duration").flatMap(parseAsDuration) ?~ "Invalid duration."
            } yield {
              val issue = Issue(fullName, issueNumber)
              val timeEntry = TimeEntry(issue, duration, user.githubId)
              TimeEntryDAO.createTimeEntry(timeEntry)
              Ok
            }
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
        for {
          entries <- TimeEntryDAO.loggedTimeForIssue(Issue(fullName, issueNumber))
          jsonUserTimesList <- createUserTimesList(entries)
        } yield {
          Ok(JsArray(jsonUserTimesList))
        }
      }
  }

  def userInfo(user: User) =
    Json.obj("userGID" -> user.githubId, "name" -> user.fullName, "email" -> user.email)

  def showTimeForAUser(userGID: String, year: Int, month: Int)(implicit ctx: DBAccessContext): Fox[JsObject] = {
    for {
      user <- UserDAO.findOneByGID(userGID) ?~> "User not found"
      entries <- TimeEntryDAO.loggedTimeForUser(userGID, year, month)
    } yield {
      val jsonProjectsTimesList =
        entries.groupBy(_.issue.project).map {
          case (project, entries) =>
            val jsonTimeEntries = entries.map(TimeEntryDAO.formatter.writes)
            project -> JsArray(jsonTimeEntries)
        }.toList

      userInfo(user) ++ Json.obj("projects" -> JsObject(jsonProjectsTimesList))
    }
  }

  def showTimeForUser(year: Int, month: Int) = SecuredAction {
    implicit request =>
      Async {
        for {
          times <- showTimeForAUser(request.user.id.id, year, month)
        } yield {
          Ok(times)
        }
      }
  }

  def createUserTimesList(entries: List[TimeEntry]) = {
    Future.traverse(entries.groupBy(_.userGID)) {
      case (userGID, entries) =>
        UserDAO.findOneByGID(userGID).map {
          case Some(user) =>
            val jsonTimeEntries = entries.map(TimeEntryDAO.formatter.writes)
            userInfo(user) ++ Json.obj("times" -> jsonTimeEntries)
          case _ =>
            Logger.warn("No user found for gid: " + userGID)
            Json.obj()
        }
    }.map(_.filterNot(_.fields.isEmpty).toSeq)
  }

  def showTimesForInterval(year: Int, month: Int) = SecuredAction {
    implicit request =>
      Async {
        for {
          entries <- TimeEntryDAO.loggedTimeForInterval(year, month)
          jsonUserTimesList <- createUserTimesList(entries)
        } yield {
          Ok(JsArray(jsonUserTimesList))
        }
      }
  }
}
