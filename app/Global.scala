import models.services.{GithubCollaboratorActor, GithubIssueActor}
import play.api.GlobalSettings

import play.api.Application
import play.api.libs.concurrent.Akka

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 25.07.13
 * Time: 03:17
 */
object Global extends GlobalSettings{
  override def onStart(app: Application) = {
    implicit val sys = Akka.system(app)
    GithubIssueActor.start
    GithubCollaboratorActor.start
  }

}
