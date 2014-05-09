/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package controllers

import models.IssueDAO
import play.api.libs.json.{Writes, Json}
import play.api.libs.concurrent.Execution.Implicits._

object IssueController extends Controller{

  def list(owner: String, repo: String) = Authenticated.async {
    implicit request =>
      for {
        entries <- IssueDAO.findByRepo(owner + "/" + repo)
      } yield {
        Ok(Json.toJson(entries))
      }
  }
}
