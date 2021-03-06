Backbone = require("backbone")

class UsersCollection extends Backbone.Collection

  url : "/api/users"

  getNameById : (id) ->

    if user = @findWhere(id : parseInt(id))
      return user.get("fullName")
    else
      throw new Error("Couldn't find user with id: #{id}")

  getGithubNameById : (id) ->

    if user = @findWhere(id : parseInt(id))
      return user.get("githubLogin")
    else
      #in rare cases user could be delete from the server
      "<Deleted User>"

module.exports = UsersCollection