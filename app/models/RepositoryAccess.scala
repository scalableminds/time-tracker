/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models

import play.api.libs.json.Json

case class RepositoryAccess(name: String, isAdmin: Boolean, isPusher: Boolean)

object RepositoryAccess{
  implicit val repositoryAccessFormat = Json.format[RepositoryAccess]
}