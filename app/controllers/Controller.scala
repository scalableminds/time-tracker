package controllers

import play.api.mvc.{Controller => PlayController, Request}
/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 14:39
 */
trait Controller extends PlayController{
  def postParameter(parameter: String)(implicit request: Request[Map[String, Seq[String]]]) =
    request.body.get(parameter).flatMap(_.headOption)
}
