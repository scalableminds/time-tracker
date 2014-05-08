/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models.auth

import java.util.UUID
import play.api.cache.Cache
import play.api.Play.current

object RedirectionCache{
  def cacheKey(id: String) =
    s"redirectUri-$id"

  def store(redirectUri: String): String = {
    val id = UUID.randomUUID().toString
    Cache.set(cacheKey(id), redirectUri)
    id
  }

  def retrieve(id: String): Option[String] = {
    Cache.getAs[String](cacheKey(id))
  }
}