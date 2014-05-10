/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models

import play.api.libs.json.Json

case class IssueReference(project: String, number: Int)

object IssueReference {
  implicit val issueFormatter = Json.format[IssueReference]
}