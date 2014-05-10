/*
 * Copyright (C) 20011-2014 Scalable minds UG (haftungsbeschränkt) & Co. KG. <http://scm.io>
 */
package models

object DurationParser {
  val durationRx = """^\s*(\-?)\s*(?:(\d+)\s*d)?\s*(?:(\d+)\s*h)?\s*(?:(\d+)\s*m)?\s*$""" r

  def parse(s: String) = {
    durationRx.findFirstMatchIn(s).map {
      case durationRx(_sign, _d, _h, _m) =>
        val sign = if (_sign == null || _sign == "") 1 else -1
        val d = if (_d == null) 0 else _d.toInt
        val h = if (_h == null) 0 else _h.toInt
        val m = if (_m == null) 0 else _m.toInt

        sign * ((d * 8 + h) * 60 + m)
    }
  }
}