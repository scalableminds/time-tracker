### define
underscore : _
backbone.marionette : Marionette
./billing_rates_item : BillingRatesItemView
models/admin/billing_rates_collection : BillingRatesCollection
###

class BillingRatesPanel extends Backbone.Marionette.CompositeView

  template: _.template("""
    <header class="row">
      <h3 class="col-md-10 col-sm-10 col-xs-9">Billing Rates</h3>
      <div class="col-md-2 col-sm-2 col-xs-3" >
	<button type="button" class="btn btn-block btn-default" id="button_create_rate">
	  <span class="glyphicon glyphicon-plus">
	</button>
      </div>
    </header>
    <section class="row hidden fade" id="section_create_new">
      <div class="input-group col-md-5 col-sm-5">
	<span class="input-group-addon"><i class="glyphicon glyphicon-briefcase"></i></span>
	<input type="text" id="input_project_name" class="form-control" required placeholder="Project Name">
      </div>
      <div class="input-group col-md-5 col-sm-5">
	<span class="input-group-addon"><i class="glyphicon glyphicon-euro"></i></span>
	<input type="number" id="input_rate" class="form-control" required placeholder="Hourly Rate">
      </div>
      <div class="col-md-2 col-sm-2">
	<button type="button" class="btn btn-block btn-default" id="button_add_rate">OK</button>
      </div>
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

    @collection = new BillingRatesCollection()


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

      @ui.$inputProjectName.val("")
      @ui.$inputRate.val("")
      @ui.$inputProjectName.val("")