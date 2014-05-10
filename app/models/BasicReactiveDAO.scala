/*
* Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
*/
package models

import braingames.reactivemongo.SecuredMongoDAO
import play.modules.reactivemongo.ReactiveMongoPlugin
import play.api.Play

trait BasicReactiveDAO[T] extends SecuredMongoDAO[T]{
  implicit val application = Play.current
  val db = ReactiveMongoPlugin.db
}