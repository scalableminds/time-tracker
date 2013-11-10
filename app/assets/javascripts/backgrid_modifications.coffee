### define ###

BackgridModifications = (options = {}) ->

  # avoids ugly <a> tags in header
  MinimalHeaderCell: Backgrid.HeaderCell.extend(

    render: -> 
      # is basically a copy of the standard render-function without any sorting carets etc

      @$el.empty()
      $label = @column.get("label")
      @$el.append($label)
      @delegateEvents()
      return @
    
  )
  
  # allows for styled section-rows
  # additionalData may yield the following attributes:
  #   className: is a string which specifies the css class for the entire table-row
  #   getCellClass: is a function which takes the cellIndex and returns the css class which the cell shall have

  StylableRow: Backgrid.Row.extend(
    
    events:
      "style" : "onStyle"


    onStyle: ->

      additionalData = @model.attributes.additionalData

      @styleRow(additionalData.className)
      @styleCells(additionalData.getCellClass)
    

    styleRow: (className) ->

      if className?
        @$el.addClass(className)


    styleCells: (getCellClass) ->

        unless getCellClass?
          return

        $(@el).find("td").each( (index, element) ->
          cellClass = getCellClass(index)
          if cellClass
            $(element).addClass(cellClass)
        )

  )


  ClickableCell: Backgrid.Cell.extend(
    
    events:

      "click" : "onClick"
    
    onClick: ->

      # deliver the right context
      options["cellOnClick"]?.call(@)
     

  )
