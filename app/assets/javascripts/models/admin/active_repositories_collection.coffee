### define
underscore : _
backbone : Backbone
###

class ActiveRepositoriesCollection extends Backbone.Collection

  constructor : ->

    # Fetch the data with AJAX
    # $.ajax or Backbone.Model.fetch ....
    data = [
      {id: 123, repository: "scalableminds/auth-proxy", accessToken: 1234567, adminId: 123},
      {id: 123, repository: "scalableminds/autodeploy", accessToken: 1234567, adminId: 123},
    ]

    super(data)