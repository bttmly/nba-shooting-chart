window.App or= {}

# largely from http://bl.ocks.org/mbostock/7833311
App.drawD3 = ( shots ) ->
  width = 1000
  height = 940
  hexRadius = 23
  threshold = 30

  xVals = _.pluck( shots, "x" )
  yVals = _.pluck( shots, "y" )
  xRange = [ xVals.min(), xVals.max() ]
  yRange = [ yVals.min(), yVals.max() ]

  xScale = d3.scale.linear()
    .domain xRange
    .range [0, width]

  yScale = d3.scale.linear()
    .domain [yRange[0], 940]
    .range [0, height * 2]

  shots = shots.map ( shot ) ->
    shot.scaledX = xScale( shot.x )
    shot.scaledY = yScale( shot.y )
    shot

  hexbin = d3.hexbin()
    .size([ width, height ])
    .radius( hexRadius )
    .x ( d ) -> d.scaledX
    .y ( d ) -> d.scaledY

  binned = hexbin( shots )

  binnedInfo = binned.map ( b ) ->
    o = {}
    o.l = b.length
    o.p = ( b.filter ( e ) -> e.m ).length / b.length
    o.v = b[0].v
    o.e = o.p * o.v
    o

  counts = _.pluck( binnedInfo, "l" )
  countRange = [ counts.min(), counts.max() ]

  expPts = binnedInfo.filter ( b ) ->
    b.l > 20
  .map ( b ) ->
    b.e

  expPtsRange = [ expPts.min(), expPts.max() ]

  console.log expPts

  rainbow = new Rainbow()
  rainbow.setSpectrum('#3498db', '#2ecc71', '#f1c40f', '#e67e22', '#e74c3c')
  rainbow.setNumberRange( expPtsRange[0], expPtsRange[1] )

  sizeScale = d3.scale.log()
    .domain([ threshold, countRange[1] ])
    .range([0, 1])

  svg = d3.select "body"
    .append "svg"
    .attr "width", width
    .attr "height", height

  binPct = ( bin ) ->
    ( bin.filter ( e ) -> e.m ).length / bin.length
  
  hexagon = svg.append "g"
    .attr "class", "hexagons"
    .selectAll "path"
    .data binned
    .enter()
    .append "path"
    .attr "d", hexbin.hexagon hexRadius - 0.5
    .attr "transform", ( d ) -> 
      scaleAmount = sizeScale( d.length )
      "translate(#{ d.x }, #{ d.y }) scale(#{ scaleAmount }, #{ scaleAmount })"
    .attr "visibility", ( d ) ->
      if d.length < threshold then "hidden" else "visibile"
    .style "fill", ( d ) ->
      rainbow.colourAt binPct( d ) * d[0].v
    .attr "data-percent", ( d ) -> binPct( d )
    .attr "data-attempts", ( d ) -> d.length
    .attr "data-value", ( d ) -> d[0].v

