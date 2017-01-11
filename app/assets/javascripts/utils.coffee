_ = require("underscore")

module.exports = Utils =

  zeroPad : (number, digits = 2) ->

    number = "" + number
    while number.length < digits
      number = "0#{number}"
    number


  sum : (arr, key) ->

    if arguments.length == 1
      arr.reduce(( (r, a) -> r + a ), 0)

    else
      arr.reduce(( (r, a) -> r + a[key] ), 0)


  decimalPlaces : (number, digits) ->

    return parseInt(Math.pow(10, digits) * number) / Math.pow(10, digits)


  minutesToHours : (minutes) ->

    return @decimalPlaces(minutes / 60, 2)


  dateToUrl : (date) ->

    return "#{date.year()}/#{date.month() + 1}"


  range : (start, end) ->

    return (i for i in [start..end])

