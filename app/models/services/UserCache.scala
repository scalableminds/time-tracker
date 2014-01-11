package models.services

import play.api.cache.Cache
import play.api.Play.current
import models.UserDAO
import braingames.reactivemongo.GlobalDBAccess
import securesocial.core.IdentityId

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 20.07.13
 * Time: 00:15
 */
object UserCache extends GlobalDBAccess{
  val userCacheTimeout = current.configuration.getInt("director.user.cacheTimeout") getOrElse 300
  val userCacheKeyPrefix = current.configuration.getString("director.user.cacheKey") getOrElse "user"

  def cacheKeyForUser(id: IdentityId): String =
    cacheKeyForUser(id.providerId, id.userId)

  def removeUserFromCache(id: IdentityId) =
    Cache.remove(cacheKeyForUser(id))

  def cacheKeyForUser(p: String, id: String) =
    s"$userCacheKeyPrefix.$p.$id"

  def findUser(id: IdentityId) = {
    Cache.getOrElse(cacheKeyForUser(id), userCacheTimeout) {
      UserDAO.findOneByUserId(id)
    }
  }

  def findUser(email: String, providerId: String) = {
    Cache.getOrElse(cacheKeyForUser(email, providerId), userCacheTimeout) {
      UserDAO.findOneByEmailAndProvider(email, providerId)
    }
  }
}