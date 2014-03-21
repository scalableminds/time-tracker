### define
backbone : backbone
moment : moment
###

class TeamTimeModel extends Backbone.Model

  parse : (response) ->

    response.times = new Backbone.Collection(response.times)

    return response