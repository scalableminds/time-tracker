### define
underscore : _
backbone : backbone
###

class UsersCollection extends Backbone.Collection

  url : "/api/users"

  getNameById : (id) ->

    if user = @findWhere(id : parseInt(id))
      return user.get("fullName")
    else
      throw new Error("Couldn't find user with id: #{id}")