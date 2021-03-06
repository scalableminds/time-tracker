/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models.auth

import models.BasicReactiveDAO
import play.api.libs.json.Json
import java.security.SecureRandom
import java.math.BigInteger
import com.scalableminds.util.reactivemongo.DBAccessContext
import com.scalableminds.util.auth.Session

object SessionService{
  def createSession(userId: Int)(implicit ctx: DBAccessContext) = {
    val random = new SecureRandom()
    val sessionId = new BigInteger(130, random).toString(32)
    SessionDAO.insert(Session(sessionId, userId))
    sessionId
  }

  def removeSessions(userId: Int)(implicit ctx: DBAccessContext) = {
    SessionDAO.removeAllOf(userId)
  }

  def resolve(token: String)(implicit ctx: DBAccessContext) = {
    SessionDAO.findByToken(token).flatMap{ session =>
      UserService.find(session.userId)
    }
  }
}

object SessionDAO extends BasicReactiveDAO[Session] {
  val collectionName = "sessions"

  val formatter = Session.sessionFormat

  def findByToken(t: String)(implicit ctx: DBAccessContext) = {
    findOne("token", t)
  }

  def removeAllOf(userId: Int)(implicit ctx: DBAccessContext) = {
    remove("userId", userId)
  }
}