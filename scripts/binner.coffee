# This is a Web Worker which bins shooting data.
    
  self.addEventListener "message", ( event ) ->

    if event.data.cmd is "stop"
      self.close()

    else if event.data.cmd is "start"

      importScripts("/bower_components/lodash/dist/lodash.min.js", "two-dim-arr.js")
      dataToBins( event.data.msg )

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

  collectify = ( headers, arrays ) ->
    _.object( headers, array ) for array in arrays

  toBins = ( data, optHash ) ->

    dim1 = optHash.dim1
    dim2 = optHash.dim2

    # dim1vals = _.pluck( data, dim1 )
    # dim2vals = _.pluck( data, dim2 )

    # dim1range = [ _.min( dim1vals ), _.max( dim1vals ) ]
    # dim2range = [ _.min( dim2vals ), _.max( dim2vals ) ]

    dim1range = optHash.dim1range or [ _.min( _.pluck( data, dim1 ) ), _.max( _.pluck( data, dim1 ) ) ]
    dim2range = optHash.dim2range or [ _.min( _.pluck( data, dim2 ) ), _.max( _.pluck( data, dim2 ) ) ]

    dim1size = parseInt( optHash.dim1size, 10 ) or ( ( dim1range[0] - dim1range[1] ) / optHash.dim1len )
    dim2size = parseInt( optHash.dim2size, 10 ) or ( ( dim2range[0] - dim2range[1] ) / optHash.dim2len  )

    dim1minBin = Math.floor( dim1range[0] / dim1size )
    dim1maxBin = Math.ceil( dim1range[1] / dim1size )

    dim2minBin = Math.floor( dim2range[0] / dim2size )
    dim2maxBin = Math.ceil( dim2range[1] / dim2size )

    # Need to add 1 for the zero-th item.
    bins = new TwoDimensionalArray 1 + dim1maxBin - dim1minBin, 1 + dim2maxBin - dim2minBin, ( d1, d2 ) ->
      ret = []
      ret.dim1range = [ d1 * dim1size, ( d1 + 1 ) * dim1size ]
      ret.dim2range = [ d2 * dim1size, ( d2 + 1 ) * dim2size ]
      return ret

    for datum in data
      d1 = ( ~~( datum[dim1] / dim1size ) ) + Math.abs( dim1minBin )
      d2 = ( ~~( datum[dim2] / dim2size ) ) + Math.abs( dim2minBin )
      try 
        bins[d1][d2].push( datum )
      catch
        throw new Error "push failed on #{ d1 }, #{ d2 }"

    bins: bins
    dim:
      dim1: dim1
      dim2: dim2
      dim1range : dim1range
      dim2range : dim2range
      dim1size : dim1size
      dim2size : dim2size

  dataToBins = ( msg ) ->

        rawShootingCollection = collectify( msg.data.resultSets[0].headers, msg.data.resultSets[0].rowSet )

        cleanShooting = []
        rawShootingCollection.forEach ( shot ) ->
          newShot = {}
          newShot.m = shot.SHOT_MADE_FLAG
          newShot.x = shot.LOC_X
          newShot.y = shot.LOC_Y
          newShot.v = parseInt shot.SHOT_TYPE.charAt 0
          cleanShooting.push newShot

        res = toBins( cleanShooting, msg.binOpts )

        shotBins = res.bins
        binDim = res.dim

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
            bin.e = bin.p * bin.v
            return bin
          else
            return false

        threshold = msg.binOpts.threshold or 1

        minimalBins = _( pctBins )
        .flatten()
        .filter ( b ) ->
          return b.a >= threshold
        .value()

        postMsg = 
          type : "result"
          msg :
            bins : minimalBins
            dim : binDim

        self.postMessage( postMsg )
        self.close()


