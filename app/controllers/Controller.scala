package controllers

import play.api.mvc.{Controller => PlayController, Request}
import braingames.mvc.ExtendedController
import braingames.reactivemongo.{AuthedAccessContext, DBAccessContext}
import securesocial.core.SecuredRequest
import models.User

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 14:39
 */
trait Controller extends PlayController with ExtendedController with ProvidesAccessContext{
  def postParameter(parameter: String)(implicit request: Request[Map[String, Seq[String]]]) =
    request.body.get(parameter).flatMap(_.headOption)
}


trait ProvidesAccessContext{
  implicit def securedRequestToDBAccess(implicit request: SecuredRequest[_]): DBAccessContext = {
    AuthedAccessContext(request.user.asInstanceOf[User])
  }

  implicit def userToDBAccess(user: User): DBAccessContext = {
    AuthedAccessContext(user)
  }
}
