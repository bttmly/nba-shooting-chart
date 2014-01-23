window.ps = 

  # shotChartAjax:
  #   url: "http://stats.nba.com/stats/shotchartdetail"
  #   callback: "jsonpCallback"
  #   data:
  #     'Season': '2013-14'
  #     'SeasonType': 'Regular Season'
  #     'LeagueID': '00'
  #     'TeamID': '0'
  #     'PlayerID': '0'
  #     'GameID': ''
  #     'Outcome': ''
  #     'Location': ''
  #     'Month': '0'
  #     'SeasonSegment': ''
  #     'DateFrom': ''
  #     'DateTo': ''
  #     'OpponentTeamID': '0'
  #     'VsConference': ''
  #     'VsDivision': ''
  #     'Position': ''
  #     'RookieYear': ''
  #     'GameSegment': ''
  #     'Period': '0'
  #     'LastNGames': '0'
  #     'ContextFilter': ''
  #     'ContextMeasure': 'FG_PCT'
  #     'zone-mode': 'basic'

  # finishedRequests : 0

  # cleanShots : []

  getShootingData : ->
    $.getJSON "data/shooting-data-2012-13.json", ( data ) ->
      console.log "2012-13 shooting data retreived"
      ps.shots = data

      ps.binSize = 10

      ps.binData = ps.bin( ps.shots, "X", "Y", ps.binSize, false )

      ps.drawBins()

  # getTeamShootingData : ( teamId ) ->
  #   ajax = ps.shotChartAjax
  #   data = $.extend ajax.data,
  #     PlayerID: 0
  #     TeamID: teamId
  #     Season: '2012-13'
  #   $.ajax
  #     type: "GET"
  #     url: ajax.url
  #     data: data
  #     jsonpCallback: "jsonpCallback"
  #     contentType: "application/json"
  #     dataType: "jsonp"
  #     done: ( json ) ->
  #       console.log "TEAM SHOOTING DATA SUCCESS"
  #     fail: ( err ) ->
  #       console.log err
  #   .then ( json ) ->

  #     Array.prototype.last = ->
  #       return this[ this.length - 1 ]

  #     ps.collectify( json.resultSets[0].headers, json.resultSets[0].rowSet ).forEach ( shot ) ->
  #       ps.cleanShots.push
  #         MADE: shot.SHOT_MADE_FLAG
  #         MIN_REM: shot.MINUTES_REMAINING
  #         SEC_REM: shot.SECONDS_REMAINING
  #         Q: shot.PERIOD
  #         X: shot.LOC_X
  #         Y: shot.LOC_Y
  #         TYPE: shot.SHOT_TYPE.split(" ")[0].charAt(0)
  #         ZONE: shot.SHOT_ZONE_AREA.split("(").last().slice(0, -1)
  #         DIST: shot.SHOT_DISTANCE
  #         ACT: shot.ACTION_TYPE

  #     console.log "DONE!"

  # collectify : ( headers, arrays ) ->
  #   _.object( headers, array ) for array in arrays

  bin : ( collection, xProp, yProp, size, byRow ) ->
    # _collection = new Backbone.Collection( collection )

    xVals = _.pluck( collection, xProp )
    xRange = [ _.min( xVals ), _.max( xVals )]

    yVals = _.pluck( collection, yProp )
    yRange = [ _.min( yVals ), _.max( yVals )]

    xMinBucket = Math.floor( xRange[0] / size )
    xMaxBucket = Math.ceil( xRange[1] / size )

    yMinBucket = Math.floor( yRange[0] / size )
    yMaxBucket = Math.ceil( yRange[1] / size )

    ps.actualBins = []
    ps.pctBins = []

    if !byRow 
      for x in [xMinBucket..xMaxBucket]
        ps.actualBins.push []

      for bin in ps.actualBins
        for y in [yMinBucket..yMaxBucket]
          bin.push []

      for x in [xMinBucket..xMaxBucket]
        ps.pctBins.push []

      for bin in ps.pctBins
        for y in [yMinBucket..yMaxBucket]
          bin.push []

    else
      for y in [yMinBucket..yMaxBucket]
        ps.actualBins.push []

      for bin in ps.actualBins
        for x in [xMinBucket..xMaxBucket]
          bin.push []

      for y in [yMinBucket..yMaxBucket]
        ps.pctBins.push []

      for bin in ps.pctBins
        for x in [xMinBucket..xMaxBucket]
          bin.push []      

    for shot in collection
      xCoord = ( ~~( shot.X / size ) ) + Math.abs( xMinBucket )
      yCoord = ( ~~( shot.Y / size ) ) + Math.abs( yMinBucket )
      
      if !byRow
        ps.actualBins[xCoord][yCoord].push shot
      else
        ps.actualBins[yCoord][xCoord].push shot

    if !byRow
      for x in [0..ps.actualBins.length - 1]
        for y in [0..ps.actualBins[x].length - 1]

          shots = ps.actualBins[x][y]
          
          if shots.length
            console.log shots[0].TYPE
          
          val = if shots.length then parseInt(shots[0].TYPE) else null
          made = _.where( shots, {MADE: 1} )
          pct = if shots.length then made.length / shots.length else 0

          ps.pctBins[x][y] = 
            pct : pct
            att : shots.length
            x : x - Math.abs( xMinBucket )
            y : y - Math.abs( yMinBucket )
            v : val

    else
      for y in [0..ps.actualBins.length - 1]
        for x in [0..ps.actualBins[y].length - 1]



          shots = ps.actualBins[y][x]

          val = if shots.length then parseInt(shots[0].TYPE) else null
          made = _.where( shots, {MADE: 1} )
          pct = if shots.length then made.length / shots.length else 0

          ps.pctBins[y][x] = 
            pct : pct
            att : shots.length
            x : x - Math.abs( xMinBucket )
            y : y - Math.abs( yMinBucket )
            v : val

    return {
      xVals : xVals
      yVals : yVals
      xRange : xRange
      yRange : yRange
      xMinBucket : xMinBucket
      xMaxBucket : xMaxBucket
      yMinBucket : yMinBucket
      yMaxBucket : yMaxBucket
      # bins : bins
    }

  drawBins : ( expectedPoints, byRow ) ->

    threshold = 20

    $( "head" ).append """
    <style>
      * { box-sizing: border-box }
      .shot-column { margin-left: .1px; float: left }
      .shot-row { width: auto }
    </style>
    """
    htmlStr = "<div class='shots'>"

    if !byRow
      ps.pctBins.forEach ( x, i ) ->
        htmlStr += "<div class='shot-column cf'>"
        x.forEach ( y, j ) ->
          if j  * ps.binSize < 375
            htmlStr += "<div class='shot-cell' data-x-coord='#{i}' data-y-coord='#{j}' data-shot-pct='#{y.pct}' data-shot-att='#{y.att}' data-shot-value='#{y.v}'></div>"
        htmlStr += "</div>"

    else
      ps.pctBins.forEach ( y, i ) ->
        htmlStr += "<div class='shot-row cf'>"
        y.forEach ( x, j ) ->
          if i  < 37
            htmlStr += "<div class='shot-cell' data-x-coord='#{j}' data-y-coord='#{i}' data-shot-pct='#{x.pct}' data-shot-att='#{x.att}' data-shot-value='#{x.v}'></div>"
        htmlStr += "</div>"

      htmlStr += "</div>"
    
    htmlStr += """
<div class="tooltip" id="tooltip">
  <p>Attempts: <span id="shooting-att"></span></p>
  <p>Percent: <span id="shooting-pct"></span></p>
</div>
"""
    $( "body" ).html $( htmlStr )

    if not expectedPoints 
      rainbow = new Rainbow()
      rainbow.setSpectrum('#3498db', '#2ecc71', '#f1c40f', '#e67e22', '#e74c3c');
      rainbow.setNumberRange(.25, .75);

      $( ".shot-cell" ).each ->
        if $( this ).attr( "data-shot-att" ) > threshold
          $( this ).addClass( "meets-att-threshold" )
          pct = $( this ).attr( "data-shot-pct" )
          color = "#" + rainbow.colourAt( pct )
          $( this ).css
            backgroundColor : color
            borderBottomColor: color
            borderTopColor: color

    else
      rainbow = new Rainbow()
      rainbow.setSpectrum('#3498db', '#2ecc71', '#f1c40f', '#e67e22', '#e74c3c');
      rainbow.setNumberRange(.25, 1.75);

      $( ".shot-cell" ).each ->
        if $( this ).attr( "data-shot-att" ) > threshold
          pct = $( this ).attr( "data-shot-pct" )
          val = $( this ).attr( "data-shot-value" )
          color = "#" + rainbow.colourAt( pct * val )
          $( this ).css
            backgroundColor : color
            borderBottomColor: color
            borderTopColor: color

    $tooltip = $("#tooltip")
    $att = $("#shooting-att")
    $pct = $("#shooting-pct")

    $( "body" ).on "mouseenter", ".shot-cell", ( event ) ->
      if $( this ).attr("data-shot-att") > threshold

        $tooltip.css 
          opacity: 1
          zIndex: 100
          top: event.pageY + 20
          left: event.pageX + 20

        $att.html $(this).attr("data-shot-att")
        $pct.html Math.round( $(this).attr("data-shot-pct") * 1000 )/10 + "%"

      else
        $tooltip.css
          opacity: 0
          zIndex: -100


    $( "body" ).on "mouseleave", ".shot-cell", ( event ) ->
      $tooltip.css
        opacity: 0
        zIndex: -100


ps.getShootingData()





