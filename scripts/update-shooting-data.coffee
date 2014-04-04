# This is a Web Worker which processes shooting data.

self.addEventListener "message", ( event ) ->

  if event.data.cmd is "stop"
    self.close()

  else if event.data.cmd is "start"
    importScripts("/bower_components/lodash/dist/lodash.min.js")

    # shotChartAjax =
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

    class TwoDimensionalArray extends Array
      constructor : ( dim1size, dim2size, value = "" ) ->
        for i in [ 0...dim1size ]
          arr = []
          for j in [ 0...dim2size ]
            arr.push if typeof value is "function" then value( i, j ) else value
          this.push arr

      # Unlike vanilla Arrays, forEach is chainable.
      # Callback receives ( currentItem, rowIndex, columnIndex, 2dArray )
      forEach : ( callback ) ->
        for row, i in this
          for item, j in this[0]
            callback( item, i, j, this )
        return this

      # An alias to forEach
      each : ->
        return this.forEach( arguments )

      # Callback receives ( currentItem, rowIndex, columnIndex, 2dArray )
      map : ( callback ) ->
        map = new TwoDimensionalArray( this.length, this[0].length )
        for row, i in this
          for item, j in row
            map[i][j] = callback( item, i, j, this )
        return map

    collectify = ( headers, arrays ) ->
      _.object( headers, array ) for array in arrays

    # 
    toBins = ( data, optHash ) ->

      dim1 = optHash.dim1
      dim2 = optHash.dim2

      dim1vals = _.pluck( data, dim1 )
      dim2vals = _.pluck( data, dim2 )

      dim1range = [ _.min( dim1vals ), _.max( dim1vals ) ]
      dim2range = [ _.min( dim2vals ), _.max( dim2vals ) ]

      dim1size = optHash.dim1size or ( ( dim1range[0] - dim1range[1] ) / dim1len )
      dim2size = optHash.dim2size or ( ( dim2range[0] - dim2range[1] ) / dim2len  )

      dim1minBin = Math.floor( dim1range[0] / size )
      dim1maxBin = Math.ceil( dim1range[1] / size )

      dim2minBin = Math.floor( dim2range[0] / size )
      dim2maxBin = Math.ceil( dim2range[1] / size )

      # Need to add 1 for the zero-th item.
      bins = new TwoDimensionalArray( 1 + dim1maxBin - dim1minBin, 1 + dim2maxBin - dim2minBin, ( -> [] ) )

      for datum in data
        d1 = ( ~~( datum[dim1] / size ) ) + Math.abs( dim1minBin )
        d2 = ( ~~( datum[dim2] / size ) ) + Math.abs( dim2minBin )
        bins[d1][d2].push( datum )
      return bins
    
    # http://youmightnotneedjquery.com/
    # can pass an object as the first arugment
    # if so, obj.url will be used as url
    # and obj.data will be sent as the request's data
    getJSON = ( url, success, fail ) ->
      if typeof url is "object"
        opts = url
        url = opts.url
        data = opts.data or {}
      request = new XMLHttpRequest()
      request.open "GET", url, true
      request.onload = ->
        if request.status >= 200 and request.status < 400
          success( JSON.parse( request.responseText ) )
        else
          fail( request, request.status )
      request.onerror = ->
        throw new Error "AJAX request to #{ url } couldn't reach server."
      request.send( data )

    getJSON event.data.msg.ajaxData, ( data ) ->

        rawShootingCollection = collectify( data.resultSets[0].headers, data.resultSets[0].rowSet )
        
        # console.save( JSON.stringify( rawShootingCollection, null, 2 ), "raw-shooting-collection.json" )
        # self.postMessage JSON.stringify( rawShootingCollection, null, 2 )

        cleanShooting = []
        rawShootingCollection.forEach ( shot ) ->
          newShot = {}
          newShot.m = shot.SHOT_MADE_FLAG
          newShot.x = shot.LOC_X
          newShot.y = shot.LOC_Y
          newShot.v = parseInt shot.SHOT_TYPE.charAt 0
          cleanShooting.push newShot

        # console.save JSON.stringify( cleanShooting, null, 2 ), "clean-shooting-collection.json"
        # self.postMessage JSON.stringify( cleanShooting, null, 2 )

        binOpts =
          dim1 : "x"
          dim2 : "y"
          dim1size : 10
          dim2size : 10

        shotBins = toBins( cleanShooting, binOpts )

        # console.save JSON.stringify( shotBins, null, 2 ), "binned-shooting-data.json"
        # self.postMessage JSON.stringify( shotBins, null, 2 )

        pctBins = shotBins.map ( shots, x, y ) ->
          if shots.length
            bin = {}
            total = shots.length
            made = shots.filter( ( s ) -> return s.m ).length
            bin.a = shots.length
            bin.p = parseFloat( made / total ).toFixed( 4 )
            bin.x = x
            bin.y = y
            bin.v = shots[0].v
            return bin
          else
            return false

        # console.save JSON.stringify( pctBins, null, 2 ) , "percent-shooting-bins.json"
        # self.postMessage JSON.stringify( pctBins, null, 2 )

        threshold = event.data.msg.attThreshold or 1

        minimalBins = _( pctBins )
        .flatten()
        .filter ( b ) ->
          return b.a >= threshold
        .value()

        # console.save JSON.stringify( minimalBins, null, 2 ) , "min-bins.json"
        self.postMessage JSON.stringify( minimalBins )

    # fail callback
    , ( req, status ) ->
      throw new Error "Server responded with status #{ status }"


