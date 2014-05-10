/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
import models.GithubIssueActor
import play.api.GlobalSettings

import play.api.Application
import play.api.libs.concurrent.Akka

object Global extends GlobalSettings{
  override def onStart(app: Application) = {
    implicit val sys = Akka.system(app)
    GithubIssueActor.start
  }

}
