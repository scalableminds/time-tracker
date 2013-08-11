package models

import play.api.libs.json.Json

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

  val formatter = Json.format[Repository]

}
