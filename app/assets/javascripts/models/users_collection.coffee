### define
underscore : _
backbone : backbone
###

class UsersCollection extends Backbone.Collection

  url : "/users"

  getNameById : (id) ->

    if user = @findWhere(id : id)
      return user.get("fullName")
    else
      throw new Exception("Couldn't find user with id: #{id}")