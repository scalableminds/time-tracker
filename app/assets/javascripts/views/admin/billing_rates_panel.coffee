### define
underscore : _
backbone.marionette : Marionette
./billing_rates_item : BillingRatesItemView
models/billing_rates_collection : BillingRatesCollection
###

class BillingRatesPanel extends Backbone.Marionette.CompositeView

  template: _.template("""
    <header class="row">
      <h2 class="col-md-11 col-sm-11">Billing Rates</h2>
      <button type="button" class="btn col-md-1 col-sm-1" id="button_create_rate">
	<span class="glyphicon glyphicon-plus">
      </button>
    </header>
    <section class="row hidden fade" id="section_create_new">
      <div class="input-group col-md-6 col-sm-6">
	<span class="input-group-addon glyphicon glyphicon-briefcase"></span>
	<input type="text" id="input_project_name" class="form-control" required placeholder="Project Name">
      </div>
      <div class="input-group col-md-5 col-sm-5 col-xs-10">
	<span class="input-group-addon glyphicon glyphicon-euro"></span>
	<input type="number" id="input_rate" class="form-control" required placeholder="Hourly Rate">
      </div>
      <button type="button" class="btn col-md-1 col-sm-1 col-xs-2" id="button_add_rate">OK</button>
    </section>
    <table class="table table-striped table-hover">
      <thead class="col-md-12">
	<tr>
	  <th>Project Name</th>
	  <th>Rate / Hour</th>
	</tr>
      </thead>
      <tbody></tbody>
    </table>
  """)

  itemView: BillingRatesItemView
  itemViewContainer: "tbody"
  events:
    "click #button_create_rate": "showInput"
    "click #button_add_rate": "addItem"

  ui:
    $buttonCreateRate: "#button_create_rate"
    $buttonAddRate: "#button_add_rate"
    $sectionCreateNew: "#section_create_new"
    $inputProjectName: "#input_project_name"
    $inputRate: "#input_rate"

  initialize : ->

    @collection = new BillingRatesCollection


  showInput: ->

    @ui.$sectionCreateNew.removeClass("hidden")
    window.setTimeout (=> @ui.$sectionCreateNew.addClass("in")), 100


  addItem: ->

    if @ui.$inputProjectName[0].checkValidity() and @ui.$inputRate[0].checkValidity()
      projectName = @ui.$inputProjectName.val()
      projectRate = @ui.$inputRate.val()
      @collection.add({project: projectName, rate: projectRate})

      @ui.$sectionCreateNew.removeClass("in")
      @ui.$sectionCreateNew.addClass("hidden")
