package controllers

import securesocial.core.providers.{GitHubProvider => SGP}
import play.api.libs.ws.Response
import play.api.{Logger, Application}
import securesocial.core.{AuthenticationException, OAuth2Info}

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 06.10.13
 * Time: 11:12
 */
class GitHubProvider(app: Application) extends SGP(app) {
  def regexForUrlEncodedParameter(name: String) = {
    (".*" + name + "=" + "([^=&\\?]*)") r
  }

  def extractParameter(body: String, name: String) = {
    val r = regexForUrlEncodedParameter(name)

    r.findFirstMatchIn(body).map(_.group(1))
  }

  override protected def buildInfo(response: Response): OAuth2Info = {
    val token = extractParameter(response.body, AccessToken)
    val tokenType = extractParameter(response.body, AccessToken)

    (token, tokenType) match {
      case (Some(t), Some(tt)) => OAuth2Info(t, Some(tt), None)
      case _ =>
        Logger.error("[securesocial] invalid response format for accessToken.")
        throw new AuthenticationException()

    }
  }
}
