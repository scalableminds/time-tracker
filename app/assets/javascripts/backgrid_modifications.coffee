### define ###

BackgridModifications = (options = {}) ->

  # avoids ugly <a> tags in header
  MinimalHeaderCell: Backgrid.HeaderCell.extend(

    render: -> 

      @$el.empty()
      $label = @column.get("label")
      @$el.append($label)
      @delegateEvents()
      return @
    
  )
  
  # allows for styled section-rows
  # set the css class of a row via the attribute className
  StylableRow: Backgrid.Row.extend(
    
    events:
      "style" : "onStyle"


    onStyle: ->

      className = @model.attributes.className
      if className
        @$el.addClass(className)

  )


  ClickableCell: Backgrid.Cell.extend(
    
    events:

      "click" : "onClick"
    
    onClick: ->

      # deliver the right context
      options["cellOnClick"]?.call(@)
     

  )
