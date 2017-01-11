/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package models

import com.scalableminds.util.reactivemongo.SecuredMongoDAO
import play.modules.reactivemongo.ReactiveMongoApi
import play.api.Play

trait BasicReactiveDAO[T] extends SecuredMongoDAO[T] with StaticReactiveMongoMixin{
  implicit val application = Play.current
  lazy val db = reactiveMongoApi.db
}

trait StaticReactiveMongoMixin{
  // TODO: this needs fixing. Instead of accessing the db instance this way, it should
  // be injected into the models by the controler using them
  lazy val reactiveMongoApi = play.api.Play.current.injector.instanceOf[ReactiveMongoApi]
}