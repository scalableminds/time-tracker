/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package models

import play.api.libs.json.Json
import braingames.reactivemongo.DBAccessContext
import play.api.libs.concurrent.Execution.Implicits._

case class Issue(fullRepoName: String, number: Int, title: String)

object Issue{
  implicit val issueFormat = Json.format[Issue]
}

object IssueDAO extends BasicReactiveDAO[Issue] {
  val collectionName = "issues"

  implicit val formatter = Issue.issueFormat

  def findByNumberAndRepo(number: Int, fullRepoName: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(
      Json.obj("number" -> number, "fullRepoName" -> fullRepoName)
    ).one[Issue]
  }

  def findByRepo(fullRepoName: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(Json.obj("fullRepoName" -> fullRepoName)).cursor[Issue].collect[List]()
  }

  def archiveIssue(issue: Issue)(implicit ctx: DBAccessContext) = {
    val jsIssue = Json.obj("number" -> issue.number, "fullRepoName" -> issue.fullRepoName)
    update(jsIssue, Json.obj("$set" -> Json.toJson(issue) ), upsert = true)
  }

}
