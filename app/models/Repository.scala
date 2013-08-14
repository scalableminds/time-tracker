package models

import play.api.libs.json.Json
import braingames.reactivemongo.DBAccessContext
import play.api.libs.concurrent.Execution.Implicits._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 22.07.13
 * Time: 01:54
 */
case class Repository(fullName: String, accessToken: String){
  def owner = fullName.split("/").head
  def name = fullName.split("/").last
}

object RepositoryDAO extends BasicReactiveDAO[Repository]{
  val collectionName = "repositories"

  def createFullName(owner: String, repo: String) =
    owner + "/" + repo

  implicit val formatter = Json.format[Repository]

  def findByName(fullName: String)(implicit ctx: DBAccessContext) = {
    collectionFind(Json.obj("fullName" -> fullName)).one[Repository]
  }
}
