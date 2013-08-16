package models.services

import akka.actor.Actor
import models.{RepositoryDAO, Repository}
import controllers.GithubApi
import braingames.util.StartableActor
import controllers.GithubIssue
import play.api.Logger
import braingames.reactivemongo.GlobalDBAccess
import scala.concurrent.duration._
import braingames.mvc.BoxImplicits

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 25.07.13
 * Time: 02:23
 */
case class CollectCollaborators(fullName: String)

case class Start()

class GithubCollaboratorActor extends Actor with GlobalDBAccess with BoxImplicits {
  implicit val ec = context.system.dispatcher

  val repositoryStartGap = 30 seconds
  val collaboratorQueryInterval = 10 minutes

  override def preStart {
    self ! Start()
  }

  def receive = {
    case Start() =>
      RepositoryDAO.findAll.map(_.foldLeft(0 seconds) {
        case (start, repository) =>
          context.system.scheduler.scheduleOnce(start, self, CollectCollaborators(repository.fullName))
          start + repositoryStartGap
      })
    case CollectCollaborators(repositoryName) =>
      Logger.debug(s"Collecting collaborators of $repositoryName...")
      collectCollaborators(repositoryName)

  }

  def collectCollaborators(repositoryName: String) = {
    RepositoryDAO.findByName(repositoryName).map {
      case Some(repository) =>
        GithubApi.listCollaborators(repository.accessToken, repository.fullName).map {
          collaborators =>
            Logger.debug(s"Found Collaborators ${collaborators.mkString(", ")} for $repositoryName")
            RepositoryDAO.updateCollaborators(repository.fullName, collaborators.map(_.toString))
            context.system.scheduler.scheduleOnce(collaboratorQueryInterval, self, CollectCollaborators(repositoryName))
        }
      case _ =>
        Logger.debug(s"CollaboratorActor couldn't find repository $repositoryName")
    }
  }
}

object GithubCollaboratorActor extends StartableActor[GithubCollaboratorActor] {
  val name = "githubCollaboratorActor"
}
