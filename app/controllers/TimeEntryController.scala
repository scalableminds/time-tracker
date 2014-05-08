package controllers

import models._
import braingames.reactivemongo.{GlobalAccessContext, DBAccessContext}
import views.html
import play.api.libs.concurrent.Execution.Implicits._
import braingames.util.ExtendedTypes._
import scala.concurrent.Future
import play.api.libs.json._
import models.User
import braingames.util.Fox
import play.api.Logger
import controllers.auth.UserAwareRequest
import net.liftweb.common.{Full, Failure}

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 13:21
 */

object DurationParser {
  val durationRx = """^\s*(\-?)\s*(?:(\d+)\s*d)?\s*(?:(\d+)\s*h)?\s*(?:(\d+)\s*m)?\s*$""" r

  def parse(s: String) = {
    durationRx.findFirstMatchIn(s).map {
      case durationRx(_sign, _d, _h, _m) =>
        val sign = if (_sign == null || _sign == "") 1 else -1
        val d = if (_d == null) 0 else _d.toInt
        val h = if (_h == null) 0 else _h.toInt
        val m = if (_m == null) 0 else _m.toInt

        sign * ((d * 8 + h) * 60 + m)
    }
  }
}

object TimeEntryController extends Controller {
  val DefaultAccessRole = None

  case class TimeEntryPost(duration: String, comment: Option[String], timestamp: Long = System.currentTimeMillis())

  implicit val timeEntryPostFormat = Json.format[TimeEntryPost]

  def parseAsDuration(s: String) = {
    DurationParser.parse(s)
  }

  def userFromRequestOrKey(accessKey: String)(implicit request: UserAwareRequest[_]) = {
    for {
      u1 <- Future.successful(request.userOpt.map(u => (u.asInstanceOf[User])))
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

  def create(owner: String, repo: String, issueNumber: Int, accessKey: String) = UserAwareAction.async(parse.json) {
    implicit request =>
      val fullName = Repository.createFullName(owner, repo)
      for {
        user <- userFromRequestOrKey(accessKey) ?~> "Unauthorized."
        repository <- RepositoryDAO.findByName(Repository.createFullName(owner, repo))(user) ?~> "Repository couldn't be found"
        _ <- ensureCollaboration(user, repository).toFox
        timeEntryPost <- request.body.asOpt[TimeEntryPost] ?~> "Invalid time entry supplied."
        duration <- parseAsDuration(timeEntryPost.duration) ?~> "Invalid duration supplied."
      } yield {
        val issue = Issue(fullName, issueNumber)
        val timeEntry = TimeEntry(issue, duration, user.userId, timeEntryPost.comment, timeEntryPost.timestamp)
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

  def createForm(owner: String, repo: String, issueNumber: Int, referer: Option[String]) = Authenticated.async {
    implicit request =>
      for {
        repository <- RepositoryDAO.findByName(Repository.createFullName(owner, repo)) ?~> "Repository couldn't be found"
        _ <- ensureCollaboration(request.user, repository).toFox
      } yield {
        Ok(html.timeEntry(owner, repo, issueNumber))
      }
  }

  def showIssues(owner: String, repo: String) = Authenticated.async {
    implicit request =>
      for {
        entries <- IssueDAO.findByRepo(owner + "/" + repo)
      } yield {
        Ok(Json.obj("issues" -> entries))
      }
  }

  def showTimeForIssue(owner: String, repo: String, issueNumber: Int) = Authenticated.async {
    implicit request =>
      val fullName = Repository.createFullName(owner, repo)
      for {
        entries <- TimeEntryDAO.loggedTimeForIssue(Issue(fullName, issueNumber))
        jsonUserTimesList <- createUserTimesList(entries)
      } yield {
        Ok(JsArray(jsonUserTimesList))
      }
  }

  def userInfo(user: User) =
    Json.obj(
      "userId" -> user.userId,
      "name" -> user.profile.fullName,
      "email" -> user.profile.email)

  def showTimeForAUser(userId: Int, year: Int, month: Int)(implicit ctx: DBAccessContext): Fox[JsObject] = {
    for {
      user <- UserDAO.findOneByUserId(userId) ?~> "User not found"
      entries <- TimeEntryDAO.loggedTimeForUser(userId, year, month)
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
      case (userGID, entries) =>
        UserDAO.findOneByUserId(userGID).map { user =>
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
        jsonUserTimesList <- createUserTimesList(entries)
      } yield {
        Ok(JsArray(jsonUserTimesList))
      }
  }
}
