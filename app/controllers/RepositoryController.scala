/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package controllers

import play.api.mvc.Action
import play.api.Logger
import models._
import com.scalableminds.util.reactivemongo.{DBAccessContext, GlobalAccessContext}
import play.api.libs.concurrent.Execution.Implicits._
import net.liftweb.common._
import scala.concurrent.Future
import play.api.libs.json._
import play.api.libs.concurrent.Akka
import play.api.Play.current
import net.liftweb.common.Full
import com.scalableminds.util.github.GithubApi
import com.scalableminds.util.github.models.GithubIssue
import com.scalableminds.util.tools.Fox

object RepositoryController extends Controller {

  lazy val issueActor = Akka.system.actorFor("/user/" + GithubUpdateActor.name)

  def hookUrl(repositoryId: String) =
    s"${Application.hostUrl}/api/repos/$repositoryId/hook"

  def tryWithAnyAccessToken[T](tokens: List[String], body: String => Future[Boolean]) = {
    def tryNext(tokens: List[String]): Future[Boolean] = {
      tokens match {
        case token :: tail =>
          body(token).flatMap {
            case true => Future.successful(true)
            case false => tryNext(tail)
          }
        case _ =>
          Future.successful(false)
      }
    }
    tryNext(tokens)
  }

  def read(id: String) = Authenticated.async{ implicit request =>
    for{
      repo <- RepositoryDAO.findOneById(id)
      js <- Repository.publicRepositoryWrites(repo)
    } yield Ok(js)
  }

  def list(accessKey: String) = UserAwareAction.async{ implicit request =>
    for{
      user <- userFromRequestOrKey(accessKey) ?~> "Unauthorized."
      repositories <- RepositoryDAO.findAll(user)
      js <- Future.traverse(repositories)(Repository.publicRepositoryWrites)
    } yield Ok(JsArray(js))
  }

  def ensureAdminRights(user: User, repositoryName: String) = {
    user.namesOfAdminRepositories.contains(repositoryName) match {
      case true => Full(true)
      case _ => Failure("You are not allowed to access this repository")
    }
  }

  def ensureRepositoryDoesNotExist(repoName: String)(implicit ctx: DBAccessContext): Fox[Boolean] = {
    RepositoryDAO.findByName(repoName).futureBox.map{
      case Full(_) => Empty
      case Empty => Full(true)
      case f: Failure => f
    }
  }

  def add = Authenticated.async(parse.json) {
    implicit request =>
      request.body.validate(Repository.publicRepositoryReads) match {
        case JsSuccess(repo, _) =>
          if (repo.usesIssueLinks && repo.accessToken.isEmpty) {
            Future.successful(JsonBadRequest("repo.accessToken.missing"))
          } else {
            for {
              _ <- ensureAdminRights(request.user, repo.name).toFox
              _ <- ensureRepositoryDoesNotExist(repo.name) ?~> "Repository already exists"
              _ <- RepositoryDAO.insert(repo)
              js <- Repository.publicRepositoryWrites(repo)
            } yield {
              GithubApi.createWebHook(request.user.githubAccessToken, repo.name, hookUrl(repo.id))
              issueActor ! FullScan(repo, repo.accessToken getOrElse request.user.githubAccessToken)
              Ok(js)
            }
          }
        case e: JsError =>
          Future.successful(BadRequest(JsError.toFlatJson(e)))
      }
  }

  def delete(id: String) = Authenticated.async {
    implicit request =>
      for {
        repository <- RepositoryDAO.findOneById(id) ?~> "Repository not found"
        _ <- ensureAdminRights(request.user, repository.name)
      } yield {
        RepositoryDAO.removeByName(repository.name)
        JsonOk("Repository deleted")
      }
  }

  def scan(id: String) = Authenticated.async {
    implicit request =>
      for {
        repository <- RepositoryDAO.findOneById(id) ?~> "Repository not found"
        _ <- ensureAdminRights(request.user, repository.name)
      } yield {
        GithubApi.createWebHook(request.user.githubAccessToken, repository.name, hookUrl(repository.id))
        issueActor ! FullScan(repository, request.user.githubAccessToken)
        JsonOk("Recreated webhook and scanning the repo")
      }
  }

  def issueHook(id: String) = Action(parse.json) {
    implicit request =>
      for {
        action <- (request.body \ "action").asOpt[String]
        if action == "opened"
        issue <- (request.body \ "issue").asOpt[GithubIssue]
      } {
        RepositoryDAO.findOneById(id)(GlobalAccessContext).futureBox.foreach {
          case Full(repo)  =>
            repo.accessToken.map{accessToken =>
              GithubUpdateActor.ensureIssue(repo, issue, accessToken)
            }
          case _ =>
            Logger.warn(s"Issue hook triggered, but couldn't find repository $id")
        }
      }
      Ok("Thanks octocat :)")
  }

  def addNoneGithub = Authenticated.async(parse.json) {
    implicit request =>
      request.body.validate(NoneGithubRepository.publicRepositoryReads) match {
        case JsSuccess(repo, _) =>
          for {
            // _ <- ensureAdminRights(request.user, repo.name).toFox
            // _ <- ensureRepositoryDoesNotExist(repo.name) ?~> "Repository already exists"
            _ <- NoneGithubRepositoryDAO.insert(repo)
            js <- NoneGithubRepository.publicRepositoryWrites(repo)
          } yield {
            println(js)
            Ok(js)
          }
        case e: JsError =>
          Future.successful(BadRequest(JsError.toFlatJson(e)))
      }
  }

  def listNoneGithub = Authenticated.async { implicit request =>
    for {
      repositories <- NoneGithubRepositoryDAO.findAll(request.user)
      js <- Future.traverse(repositories)(NoneGithubRepository.publicRepositoryWrites)
    } yield Ok(JsArray(js))
  }

}
