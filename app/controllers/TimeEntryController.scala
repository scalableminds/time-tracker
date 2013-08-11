package controllers

import play.api.mvc.{Action}
import models.{User, TimeEntry, Issue, TimeEntryDAO}
import braingames.reactivemongo.GlobalDBAccess
import play.api.data.Form
import play.api.data.Forms._
import views.html
import play.api.libs.concurrent.Execution.Implicits._
import braingames.util.ExtendedTypes._
import scala.concurrent.Future

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 13:21
 */
object TimeEntryController extends Controller with GlobalDBAccess with securesocial.core.SecureSocial {
  val DefaultAccessRole = None

  def createFullName(owner: String, repo: String) =
    owner + "/" + repo

  def create(owner: String, repo: String, issueNumber: Int) = SecuredAction(ajaxCall = false, authorize = None, p = parse.urlFormEncoded) {
    implicit request =>
      Async {
        val fullName = createFullName(owner, repo)
        val user = request.user.asInstanceOf[User]
        GithubApi.isCollaborator(user, user.githubAccessToken, fullName).map {
          case true =>
            (for {
              duration <- postParameter("duration").flatMap(_.toIntOpt)
            } yield {
              val issue = Issue(fullName, issueNumber)
              val timeEntry = TimeEntry(issue, duration, "testUser")
              TimeEntryDAO.createTimeEntry(timeEntry)
              Ok
            }).getOrElse(BadRequest("no Valid duration suplied"))
          case false =>
            BadRequest("Not allowed.")
        }
      }
  }

  def createForm(owner: String, repo: String, issueNumber: Int) = SecuredAction {
    implicit request =>
      Ok(html.timeEntry(owner, repo, issueNumber))
  }

  def loggedTimeForIssue(owner: String, repo: String, issueNumber: Int) = SecuredAction {
    implicit request =>
      Async {
        val fullName = createFullName(owner, repo)
        TimeEntryDAO.loggedTimeForIssue(Issue(fullName, issueNumber)).map {
          entries =>
            val timeByUser = entries.groupBy(_.user)
            Ok(html.timesPerIssue(timeByUser))
        }
      }
  }
}
