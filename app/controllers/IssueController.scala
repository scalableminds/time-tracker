/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package controllers

import javax.inject.Inject

import models.IssueDAO
import play.api.i18n.MessagesApi
import play.api.libs.json.{Json, Writes}
import play.api.libs.concurrent.Execution.Implicits._

class IssueController @Inject()(val messagesApi: MessagesApi) extends Controller{

  def list(owner: String, repo: String) = Authenticated.async {
    implicit request =>
      for {
        entries <- IssueDAO.findByRepo(owner + "/" + repo)
      } yield {
        Ok(Json.toJson(entries))
      }
  }
}
