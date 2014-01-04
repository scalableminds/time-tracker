### define
jquery: $
underscore : _
backbone : Backbone
###

class BillingRatesCollection extends Backbone.Collection

  constructor : ->

    # Fetch the data with AJAX
    # $.ajax or jsRoutes.....
    data = [{project: "ABC", rate: 20}, {project: "Test", rate: 40}]
    super(data)
