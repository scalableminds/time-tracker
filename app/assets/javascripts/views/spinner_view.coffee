### define
backbone.marionette : marionette
###

class SpinnerView extends Backbone.Marionette.ItemView

  className : "spinner-overlay"

  template : _.template("""
    <div class="v-center">
      <div class="v-center-agent">
        <div class="spinner">
          <i class="fa fa-refresh fa-3x"></i>
        </div>
      </div>
    </div>
  """)

  initialize : ->

    if @model
      @listenTo(@model, "sync", @hide)

    if @collection
      @listenTo(@collection, "sync", @hide)


  show : ->

    @$el.show()


  hide : ->

    @$el.hide()

