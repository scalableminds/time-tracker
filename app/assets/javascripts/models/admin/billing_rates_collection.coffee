Backbone = require("backbone")

class BillingRatesCollection extends Backbone.Collection

  constructor : ->

    # Fetch the data with AJAX
    # $.ajax or Backbone.Model.fetch ....
    data = [{project: "ABC", rate: 20}, {project: "Test", rate: 40}]
    super(data)

module.exports = BillingRatesCollection