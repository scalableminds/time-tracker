package controllers

import play.api.mvc.{Action}
import models._
import braingames.reactivemongo.{GlobalAccessContext, GlobalDBAccess, DBAccessContext}
import play.api.data.Form
import play.api.data.Forms._
import views.html
import play.api.libs.concurrent.Execution.Implicits._
import braingames.util.ExtendedTypes._
import scala.concurrent.Future
import play.api.libs.json.{JsObject, JsString, JsArray, Json}
import models.TimeEntry._
import play.api.libs.json.JsArray
import models.User
import play.api.libs.json.JsObject
import braingames.util.Fox
import play.api.Logger
import securesocial.core.RequestWithUser

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

object TimeEntryController extends Controller with securesocial.core.SecureSocial {
  val DefaultAccessRole = None

  case class TimeEntryPost(duration: String, comment: Option[String], timestamp: Long = System.currentTimeMillis())

  implicit val timeEntryPostFormat = Json.format[TimeEntryPost]

  def parseAsDuration(s: String) = {
    DurationParser.parse(s)
  }

  def userFromRequestOrKey(accessKey: String)(implicit request: RequestWithUser[_]) = {
    for{
      u1 <- Future.successful(request.user.map(u => (u.asInstanceOf[User])))
      u2 <-  UserDAO.findByAccessKey(accessKey)(GlobalAccessContext)
    } yield {
      u1 orElse u2
    }
  }

  def create(owner: String, repo: String, issueNumber: Int, accessKey: String) = UserAwareAction(p = parse.json) {
    implicit request =>
      Async {
        val fullName = RepositoryDAO.createFullName(owner, repo)
        (for {
          user <- userFromRequestOrKey(accessKey) ?~> "Unauthorized."
          repository <- RepositoryDAO.findByName(RepositoryDAO.createFullName(owner, repo))(user) ?~> "Repository couldn't be found"
          if (repository.isCollaborator(user) || repository.isAdmin(user))
          timeEntryPost <- request.body.asOpt[TimeEntryPost] ?~> "Invalid time entry supplied."
          duration <- parseAsDuration(timeEntryPost.duration) ?~> "Invalid duration supplied."
        } yield {

          val issue = Issue(fullName, issueNumber)
          val timeEntry = TimeEntry(issue, duration, user.githubId, timeEntryPost.timestamp)
          TimeEntryDAO.createTimeEntry(timeEntry)(user)
          JsonOk("OK")
        }) ?~> "Not allowed."
      }
  }

  def createGenericForm() = SecuredAction {
    implicit request =>
      Async {
        val user = request.user.asInstanceOf[User]
        for {
          usedRepos <- RepositoryDAO.findAll(GlobalAccessContext) ?~> "Not allowed."
        } yield {
          Ok(html.genericTimeEntry(usedRepos))
        }
      }
  }

  def createForm(owner: String, repo: String, issueNumber: Int) = SecuredAction {
    implicit request =>
      Async {
        val user = request.user.asInstanceOf[User]
        (for {
          repository <- RepositoryDAO.findByName(RepositoryDAO.createFullName(owner, repo)) ?~> "Repository couldn't be found"
          if (repository.isCollaborator(user) || repository.isAdmin(user))
        } yield {
          Ok(html.timeEntry(owner, repo, issueNumber))
        }) ?~> "Not allowed."
      }
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
    Json.obj(
      "userGID" -> user.githubId,
      "name" -> user.fullName,
      "email" -> user.email,
      "nick" -> user.nick)

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

  def createUserTimesList(entries: List[TimeEntry])(implicit ctx: DBAccessContext) = {
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
