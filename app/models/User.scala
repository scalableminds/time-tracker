package models

import reactivemongo.bson.BSONObjectID
import play.api.libs.json.Json
import braingames.reactivemongo.DBAccessContext
import play.api.libs.concurrent.Execution.Implicits._

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 22:36
 */
case class GithubUserInfo(token: String)

object GithubUserInfo extends Function1[String, GithubUserInfo]{
  implicit val githubUserInfoFormatter = Json.format[GithubUserInfo]
}

case class User(github: GithubUserInfo, email: String, verified: Boolean, roles: List[String]) {
  def hasRole(role: String) = roles.contains(role)
}

object UserDAO extends BasicReactiveDAO[User] {
  val collectionName = "users"

  import GithubUserInfo.githubUserInfoFormatter
  val formatter = Json.format[User]

  def findOneByEmail(email: String)(implicit ctx: DBAccessContext) =
    find("email", email).headOption()

}
