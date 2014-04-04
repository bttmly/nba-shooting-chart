window.App or= {}

App.drawChart = ( canvasId, rawBins ) ->

  rainbow = new Rainbow()
  rainbow.setSpectrum('#3498db', '#2ecc71', '#f1c40f', '#e67e22', '#e74c3c');
  rainbow.setNumberRange(.25, 1.75);
  bins = new Collection( JSON.parse( rawBins ) )

  stage = new Kinetic.Stage
    container: "kinetic-wrapper"
    width: 1000
    height: 750

  layer = new Kinetic.Layer()

  layer.add new Kinetic.Rect
    x: 0
    y: 0
    width: 1000
    height: 750

  bins.each ( bin ) ->
    rect = new Kinetic.Rect
      x : bin.x * 20
      y : bin.y * 20
      width: 20
      height: 20
      fill: "#" + rainbow.colourAt( bin.p * bin.v )

    rect.binData = bin

    layer.add( rect )

  stage.add( layer )

  $output = $( "<div id='output'>" ).appendTo( "#kinetic-wrapper" )

  stage.on "mouseover", ( event ) ->
    if ( d = event.target.binData )
      $output.html "<h5>League Average:</h5><p><strong>#{ ( d.p * 100 ).toFixed( 2 ) }%</strong> on <strong>#{ d.a }</strong> total shots. <strong>#{ ( d.p * d.v ).toFixed( 2 ) }</strong> expected points per shot.</p>"
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
