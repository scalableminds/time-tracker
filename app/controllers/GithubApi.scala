package controllers

import play.api.Play.current
import models.User
import play.api.libs.ws.WS
import play.api.libs.json._
import play.api.libs.json.Json._
import play.api.libs.json.Reads._
import play.api.libs.functional.syntax._
import play.api.Logger
import play.api.libs.concurrent.Execution.Implicits._
import securesocial.core.Identity
import play.api.libs.ws.WS.WSRequestHolder
import scala.concurrent.Future

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 23:49
 */
object GithubApi
  extends GithubOrgRequestor
  with GithubRepositoryRequestor
  with GithubCollaboratorRequestor
  with GithuIssueRequestor
  with GithubHooksRequestor {

  def hooksUrl(repo: String) = s"/repos/$repo/hooks"

  val orgsUrl = "/user/orgs"

  val userReposUrl = "/user/repos"

  def repoCollaboratorsUrl(repo: String): String = s"/repos/$repo/collaborators"

  def orgaReposUrl(orga: String) = s"/orgs/$orga/repos"

  def issuesUrl(repo: String) = s"/repos/$repo/issues"
}

trait GithubRequestor {
  val GH = "https://api.github.com"

  def githubRequest(sub: String, prependHost: Boolean = true)(implicit token: String) = {
    Logger.warn("Token: " + token)
    val url =
      if (prependHost)
        GH + sub
      else
        sub

    WS.url(url).withQueryString("access_token" -> token)
  }
}

class ResultSet[T](requestUrl: String, deserializer: Reads[T], token: String) extends GithubRequestor {

  case class LinkHeader(value: String, params: Map[String, String])

  def parseParams(rawParams: List[String]): Map[String, String] = {
    val ParamRx = """^\s*([^=]*)\s*=\s*(.*?)\s*$""".r
    rawParams.map {
      case ParamRx(typ, value) =>
        Some(typ -> value)
      case _ =>
        None
    }.flatten.toMap
  }

  def parseLinkHeader(linkHeader: String): Array[LinkHeader] = {
    linkHeader.split(",").flatMap {
      link =>
        link.split(";").toList match {
          case url :: rawParams =>
            val params = parseParams(rawParams)
            Some(LinkHeader(url.drop(1).dropRight(1), params))
          case _ =>
            None
        }
    }
  }

  def results: Future[List[T]] = {
    def requestNext(nextRequest: String): Future[List[T]] = {
      githubRequest(nextRequest)(token).get().flatMap {
        response =>
          val result = response.json.validate(deserializer).asOpt.toList

          response.header("Link").flatMap(raw =>
            parseLinkHeader(raw).find(link => link.params.get("rel").map(_ == "next").getOrElse(false))) match {
            case Some(link) =>
              requestNext(link.value).map(result ::: _)
            case _ =>
              Future.successful(result)
          }
      }

    }
    requestNext(requestUrl)
  }
}

trait GithubOrgRequestor extends GithubRequestor {

  case class GithubOrga(login: String)

  implicit val githubOrgaFormat = Json.format[GithubOrga]

  val orgsUrl: String

  def listOrgs(token: String) =
    new ResultSet(orgsUrl, extractOrgs, token).results.map {
      _.flatten.map(_.login)
    }

  val extractOrgs = (__).read(list[GithubOrga])
}

trait GithubRepositoryRequestor extends GithubRequestor {

  case class GithubRepo(full_name: String)

  implicit val githubRepoFormat = Json.format[GithubRepo]

  def userReposUrl: String

  def orgaReposUrl(orga: String): String

  def listUserRepositories(token: String) =
    new ResultSet(userReposUrl, extractRepos, token).results.map {
      results =>
        results.flatten.map(_.full_name)
    }

  def listOrgaRepositories(token: String, orga: String) =
    new ResultSet(orgaReposUrl(orga), extractRepos, token).results.map {
      results =>
        results.flatten.map(_.full_name)
    }

  val extractRepos = (__).read(list[GithubRepo])
}

trait GithubCollaboratorRequestor extends GithubRequestor {

  case class GithubCollaborator(id: Int)

  implicit val githubCollaboratorFormat = Json.format[GithubCollaborator]

  def repoCollaboratorsUrl(repo: String): String

  def isCollaborator(user: Identity, token: String, repo: String) =
    listCollaborators(token, repo).map(_.map(_.toString).contains(user.id.id))

  def listCollaborators(token: String, repo: String) =
    githubRequest(repoCollaboratorsUrl(repo))(token).get().map {
      response =>
        response.json.validate(extractCollabs).fold(
          invalid => {
            Logger.warn("An error occurred while trying to decode orgs: " + invalid)
            Nil
          },
          valid => valid.map(_.id)
        )
    }

  val extractCollabs = (__).read(list[GithubCollaborator])
}

trait GithubHooksRequestor extends GithubRequestor {

  def hooksUrl(repo: String): String

  def hook(url: String) =
    Json.obj(
      "name" -> "web",
      "active" -> true,
      "events" -> List("issues"),
      "config" -> Json.obj(
        "url" -> url,
        "content_type" -> "json"
      )
    )

  def createWebHook(token: String, repo: String, url: String) =
    githubRequest(hooksUrl(repo))(token).post(hook(url)).map {
      response =>
        Logger.info("Hook: " + response.status)
        Logger.warn("Content: " + response.json)
        response.status
    }
}

case class GithubIssue(url: String, title: String, body: String, number: Int)

trait GithuIssueRequestor extends GithubRequestor {


  implicit val githubIssueFormat = Json.format[GithubIssue]

  def issuesUrl(repo: String): String

  def listRepositoryIssues(token: String, repo: String) =
    new ResultSet(issuesUrl(repo), extractIssues, token).results.map {
      results =>
        results.flatten
    }

  def issueBodyUpdate(body: String) =
    Json.obj("body" -> body)

  def updateIssueBody(token: String, issue: GithubIssue, body: String) = {
    githubRequest(issue.url, prependHost = false)(token).patch(issueBodyUpdate(body)).map{ response =>
      Logger.info("Update reuturned: " + response.status)
    }
  }

  val extractIssues = (__).read(list[GithubIssue])
}