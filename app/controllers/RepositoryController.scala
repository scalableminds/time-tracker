package controllers

import play.api.mvc.Action
import java.io.File
import scala.reflect.io.Path
import play.api.Logger

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 15.08.13
 * Time: 23:54
 */
object RepositoryController extends Controller {

  def issueHook(owner: String, repository: String) = Action {
    implicit request =>
      Path("test.out").toFile.writeAll(request.body.asText.getOrElse(""))
      Logger.debug("test.out written :)")
      Ok("Thanks octocat :)")
  }
}
