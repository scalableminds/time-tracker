### define
underscore : _
###

Utils =
	
	zeroPad : (number, digits = 2) ->

    number = "" + number
    while number.length < digits
    	number = "0#{number}"
    number


  sum : (arr) ->

  	arr.reduce(( (r, a) -> r + a ), 0)