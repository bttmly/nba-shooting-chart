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

    rect = new Kinetic.Rect
      x : bin.x * App.binConfig.dim2size * 2
      y : bin.y * App.binConfig.dim2size * 2
      width: App.binConfig.dim1size * 2
      height: App.binConfig.dim2size * 2
      fill: "#" + rainbow.colourAt( bin.p * bin.v )
    rect.binData = bin
    layer.add( rect )

  stage.add( layer )

  $output = $( "<div id='output'>" ).appendTo( "#kinetic-wrapper" )

  stage.on "mouseover", ( event ) ->
    if ( d = event.target.binData )
      $output.html "<h5>League Average:</h5><p><strong>#{ ( d.p * 100 ).toFixed( 2 ) }%</strong> on <strong>#{ d.a }</strong> total shots. <strong>#{ ( d.e ).toFixed( 2 ) }</strong> expected points per shot.</p>"
      $output.css
        opacity: 1
        top: event.evt.clientY + 40
        left: event.evt.clientX + 40
    else
      $output.css
        opacity: 0
