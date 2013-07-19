package models.services

import models.{GithubUserInfo, UserDAO, User}
import braingames.reactivemongo.GlobalDBAccess

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 23:12
 */
object UserService extends GlobalDBAccess{

  val mockUserName = "scmboy@scalableminds.com"

  def mockUser = User(GithubUserInfo(""), mockUserName, true, List("admin"))

  def findOneByEmail(email: String) = {
    UserDAO.findOneByEmail(email)
  }
}
