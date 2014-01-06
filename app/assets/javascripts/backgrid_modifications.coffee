### define ###

BackgridModifications = ->

  # removes sorting carets in header etc.
  MinimalHeaderCell: Backgrid.HeaderCell.extend(

    render: ->
      # see also backgrids implentation of HeaderCell.render()

      @$el.empty()
      $label = @column.get("label")
      @$el.append($label)
      @delegateEvents()
      return @

  )

  # allows for styled section-rows

  StylableRow: Backgrid.Row.extend(

    render: ->

      # call super
      Backgrid.Row.prototype.render.apply(this, arguments)

      if c = @model.get("_className")
        @$el.addClass(c)

      @
  )


  ExtendedCell: Backgrid.Cell.extend(

    render: ->
      # see also backgrids implentation of Cell.render()

      @$el.empty()
      modelContent = @model.get(@column.get("name"))

      # is it a modified model?
      if modelContent.text?

        if modelContent.cellClass?
          @$el.addClass(modelContent.cellClass)

        if modelContent.onClick?
          @$el.click(modelContent.onClick)

        modelContent = modelContent.text

      # calling html instead of text allows &sum; to render correctly
      @$el.html(@formatter.fromRaw(modelContent))

      @delegateEvents()
      return @


  )
