package controllers

import play.api.mvc.{Action}
import models.{TimeEntry, Issue, TimeEntryDAO}
import braingames.reactivemongo.GlobalDBAccess
import play.api.data.Form
import play.api.data.Forms._
import views.html
import play.api.libs.concurrent.Execution.Implicits._
import braingames.util.ExtendedTypes._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 13:21
 */
object TimeEntryController extends Controller with GlobalDBAccess with Secured{
  val DefaultAccessRole = None

  def create(project: String, issueNumber: Int) = Authenticated(parser = parse.urlFormEncoded) {
    implicit request =>
      (for {
        duration <- postParameter("duration").flatMap(_.toIntOpt)
      } yield {
        val issue = Issue(project, issueNumber)
        val timeEntry = TimeEntry(issue, duration, "testUser")
        TimeEntryDAO.createTimeEntry(timeEntry)
        Ok
      }).getOrElse(BadRequest("no Valid duration suplied"))
  }

  def createForm(project: String, issueNumber: Int) = Authenticated{ implicit request =>
    Ok(html.timeEntry(project, issueNumber))
  }

  def loggedTimeForIssue(project: String, issueNumber: Int) = Authenticated {
    implicit request =>
      Async {
        TimeEntryDAO.loggedTimeForIssue(Issue(project, issueNumber)).map {
          entries =>
            val timeByUser = entries.groupBy(_.user)
            Ok(html.timesPerIssue(timeByUser))
        }
      }
  }
}
