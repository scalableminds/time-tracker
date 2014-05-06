package models

import play.api.libs.json.Json
import braingames.reactivemongo.DBAccessContext
import play.api.libs.concurrent.Execution.Implicits._

/**
 * Company: scalableminds
 * User: philippotto
 * Date: 14.11.13
 * Time: 20:55
 */

case class ArchivedIssue(fullRepoName: String, number: Int, title: String)

case class CondensedIssue(number: Int, title: String) {
  def this(issue: ArchivedIssue) = this(issue.number, issue.title)
}

object CondensedIssue {
  implicit val formatter = Json.format[CondensedIssue]
}

object IssueDAO extends BasicReactiveDAO[ArchivedIssue] {
  val collectionName = "issues"

  implicit val formatter = Json.format[ArchivedIssue]

  def findByNumberAndRepo(number: Int, fullRepoName: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(
      Json.obj("number" -> number, "fullRepoName" -> fullRepoName)
    ).one[ArchivedIssue]
  }

  def findByRepo(fullRepoName: String)(implicit ctx: DBAccessContext) = {
    val archivedIssueList = withExceptionCatcher(find(
      Json.obj("fullRepoName" -> fullRepoName)
    ).cursor[ArchivedIssue].collect[List]())

    archivedIssueList.map { l => l.map { i => new CondensedIssue(i) } }
  }

  def archiveIssue(issue: ArchivedIssue)(implicit ctx: DBAccessContext) = {
    val jsIssue = Json.obj("number" -> issue.number, "fullRepoName" -> issue.fullRepoName)
    update(jsIssue, Json.obj("$set" -> Json.toJson(issue) ), upsert = true)
  }

}
