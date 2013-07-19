package controllers

import play.api.mvc._
/**
 * Company: scalableminds
 * User: tmbo
 * Date: 19.07.13
 * Time: 23:37
 */
object Authentication extends Controller{

  def login = Action{
    Ok("LOGIN")
  }

}
