package models.auth

import play.api.cache.Cache
import play.api.Play.current
import models.UserDAO
import braingames.reactivemongo.GlobalDBAccess

/**
 * Company: scalableminds
 * User: tmbo
 * Date: 20.07.13
 * Time: 00:15
 */
object UserCache extends GlobalDBAccess{
  val userCacheTimeout = current.configuration.getInt("director.user.cacheTimeout") getOrElse 300
  val userCacheKeyPrefix = current.configuration.getString("director.user.cacheKey") getOrElse "user"

  def cacheKeyForUser(userId: Int): String =
    s"$userCacheKeyPrefix.$userId"

  def removeUserFromCache(userId: Int) =
    Cache.remove(cacheKeyForUser(userId))

  def findUser(userId: Int) = {
    Cache.getOrElse(cacheKeyForUser(userId), userCacheTimeout) {
      UserDAO.findOneByUserId(userId)
    }
  }
}