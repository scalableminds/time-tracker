/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package models

import play.api.libs.json.Json
import com.scalableminds.util.reactivemongo.DBAccessContext
import play.api.libs.concurrent.Execution.Implicits._
import com.scalableminds.util.tools.Fox

case class Issue(reference: IssueReference, title: String)

object Issue{
  implicit val issueFormat = Json.format[Issue]
}

object IssueDAO extends BasicReactiveDAO[Issue] {
  val collectionName = "issues"

  implicit val formatter = Issue.issueFormat

  def findByReferenceQ(reference: IssueReference) =
    Json.obj("reference" -> reference)

  def findByNumberAndRepo(number: Int, fullRepoName: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(
      Json.obj("reference" -> IssueReference(fullRepoName, number))
    ).one[Issue]
  }

  def findByRepo(fullRepoName: String)(implicit ctx: DBAccessContext) = withExceptionCatcher{
    find(Json.obj("reference.project" -> fullRepoName)).cursor[Issue].collect[List]()
  }

  def archiveIssue(issue: Issue)(implicit ctx: DBAccessContext) = {
    update(findByReferenceQ(issue.reference), Json.obj("$set" -> Json.toJson(issue) ), upsert = true)
  }

  def findByIssueReferences(issueReferences: List[IssueReference])(implicit ctx: DBAccessContext) = {
    Fox.sequenceOfFulls(issueReferences.grouped(100).map { refs =>
      withExceptionCatcher {
        find(Json.obj("reference" -> Json.obj("$in" -> refs))).cursor[Issue].collect[List]()
      }
    }.toList).map(_.flatten)
  }
}
