window.App or= {}

App.drawChart = ( rawBins ) ->
  bins = new Collection( rawBins )

  rainbow = new Rainbow()
  rainbow.setSpectrum('#3498db', '#2ecc71', '#f1c40f', '#e67e22', '#e74c3c')
  rainbow.setNumberRange( bins.pluck("e").min(), bins.pluck("e").max() )



  stage = new Kinetic.Stage
    container: "kinetic-wrapper"
    width: 1040
    height: 750

  layer = new Kinetic.Layer()

  layer.add new Kinetic.Rect
    x: 0
    y: 0
    width: 1040
    height: 750

  bins.each ( bin ) ->

    # rect = new Kinetic.Rect
    #   x : bin.x * App.binConfig.dim2size * 2
    #   y : bin.y * App.binConfig.dim2size * 2
    #   width: App.binConfig.dim1size * 2
    #   height: App.binConfig.dim2size * 2
    #   fill: "#" + rainbow.colourAt( bin.p * bin.v )
    # rect.binData = bin
    # layer.add( rect )

    hex = new Kinetic.RegularPolygon
      sides : 6
      x : do ->
        add = -1 * ( bin.y % 2 ) * App.binConfig.dim1size
        return add + ( bin.x * App.binConfig.dim2size * 2 )
      y : do ->
        add = -.3 * bin.y * App.binConfig.dim2size
        return add + ( bin.y * App.binConfig.dim2size * 2 )
      fill: "#" + rainbow.colourAt( bin.p * bin.v )
      radius : App.binConfig.dim1size + 3
      stroke : "#333"
      strokeWidth : 1
      scale : .5
    hex.binData = bin
    layer.add( hex )

  stage.add( layer )

  $output = $( "<div id='output'>" ).appendTo( "#kinetic-wrapper" )

  stage.on "mouseover", ( event ) ->
    if ( d = event.target.binData )
      $output.html "<h5>League Average:</h5><p><strong>#{ ( d.p * 100 ).toFixed( 2 ) }%</strong> on <strong>#{ d.a }</strong> total shots. <strong>#{ ( d.e ).toFixed( 2 ) }</strong> expected points per shot.</p>"
      $output.css
        opacity: 1
        top: event.evt.clientY + 20
        left: event.evt.clientX + 20
    else
      $output.css
        opacity: 0

  # canvas = new fabric.Canvas( canvasId )
  # canvas.setWidth(1020)  
  # canvas.setHeight(750)
  # bins.each ( bin ) ->
  #   rect = new fabric.Rect
  #     width: 20
  #     height: 20
  #     top: bin.y * 20
  #     left: bin.x * 20
  #     fill: "#" + rainbow.colourAt( bin.p * bin.v )
  #   rect.binData = bin
  #   rect.selectable = false
  #   rect.hasControls = false
  #   canvas.add( rect )

  # as in https://github.com/kangax/fabric.js/wiki/Working-with-events
  # canvas.findTarget = do ( originalFn = canvas.findTarget ) ->
  #   ->
  #     target = originalFn.apply( this, arguments )
  #     if target
  #       if this._hoveredTarget isnt target
  #         canvas.fire "object:over", target: target
  #         if this._hoveredTarget
  #           canvas.fire "object:out", target: this._hoveredTarget
  #         this._hoveredTarget = target
  #     else if this._hoveredTarget
  #       canvas.fire "object:out", target: this_hoveredTarget
  #       this._hoveredTarget = null
  #     return target

  # canvas.on "object:over", ( event ) ->
  #   console.log event
