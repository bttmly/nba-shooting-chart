window.App or= {}

ajaxSettings = 
  allTeams:
    url: "http://stats.nba.com/stats/leaguedashteamstats"
    data:
      'Season': '2013-14'
      'AllStarSeason': ''
      'SeasonType': 'Regular Season'
      'LeagueID': '00'
      'MeasureType': 'Base'
      'PerMode': 'PerGame'
      'PlusMinus': 'N'
      'PaceAdjust': 'N'
      'Rank': 'N'
      'Outcome': ''
      'Location':''
      'Month': '0'
      'SeasonSegment': ''
      'DateFrom': ''
      'DateTo': ''
      'OpponentTeamID': '0'
      'VsConference': ''
      'VsDivision': ''
      'GameSegment': ''
      'Period': '0'
      'LastNGames': '0'
      'GameScope': ''
      'PlayerExperience': ''
      'PlayerPosition': ''
      'StarterBench': ''

  eachTeam:
    url : "http://stats.nba.com/stats/commonteamroster/"
    data:
      'Season': '2013-14'
      'LeagueID': '00'
      'TeamID': ''

  shotChart:
    url: "http://stats.nba.com/stats/shotchartdetail"
    data:
      'Season': '2013-14'
      'SeasonType': 'Regular Season'
      'LeagueID': '00'
      'TeamID': '0'
      'GameID': ''
      'Outcome': ''
      'Location': ''
      'Month': '0'
      'SeasonSegment': ''
      'DateFrom': ''
      'DateTo': ''
      'OpponentTeamID': '0'
      'VsConference': ''
      'VsDivision': ''
      'Position': ''
      'RookieYear': ''
      'GameSegment': ''
      'Period': '0'
      'LastNGames': '0'
      'ContextFilter': ''
      'ContextMeasure': 'FG_PCT'
      'zone-mode': 'basic'

  lineups :
    url: "http://stats.nba.com/stats/leaguedashlineups"
    data:
      'Season': '2013-14'
      'SeasonType': 'Regular Season'
      'LeagueID': '00'
      'TeamID': ''
      'MeasureType': 'Base'
      'PerMode': 'PerGame'
      'PlusMinus': 'N'
      'PaceAdjust': 'N'
      'Rank': 'N'
      'Outcome': ''
      'Location': ''
      'Month': '0'
      'SeasonSegment': ''
      'DateFrom': ''
      'DateTo': ''
      'OpponentTeamID': '0'
      'VsConference': ''
      'VsDivision': ''
      'GameSegment': ''
      'Period': '0'
      'LastNGames': '0'
      'GroupQuantity':'5'
      'GameScope': ''
      'PlayerExperience': ''
      'PlayerPosition': ''
      'StarterBench': ''
      'pageNo': '1'
      'rowsPerPage':'0'

  sportVu : 
    [
      url: "http://stats.nba.com/js/data/sportvu/speedData.js"
      varName: "speedData"
    ,
      url: "http://stats.nba.com/js/data/sportvu/touchesData.js"
      varName: "touchesData"
    ,
      url: "http://stats.nba.com/js/data/sportvu/passingData.js"
      varName: "passingData"
    ,
      url: "http://stats.nba.com/js/data/sportvu/defenseData.js"
      varName: "defenseData"
    ,
      url: "http://stats.nba.com/js/data/sportvu/reboundingData.js"
      varName: "reboundingData"
    ,
      url: "http://stats.nba.com/js/data/sportvu/drivesData.js"
      varName: "drivesData"
    ,
      url: "http://stats.nba.com/js/data/sportvu/catchShootData.js"
      varName: "catchShootData"
    ,
      url: "http://stats.nba.com/js/data/sportvu/pullUpShootData.js"
      varName: "pullUpShootData"
    ,
      url: "http://stats.nba.com/js/data/sportvu/shootingData.js"
      varName: "shootingData"
    ]

ajaxFail = ( settings, req, status, err ) ->
  e = new Error "Ajax request to #{ settings.url } failed: #{ status }"
  e.status = status
  e.req = req
  e.originalError = err
  e.ajaxSettings = settings
  throw e

App.ajax = 

  getLeagueTeams : ->
    settings = ajaxSettings.allTeams
    $.ajax
      type: "GET"
      url: settings.url
      data: settings.data
      contentType: "application/json"
      dataType: "jsonp"
    .fail ( req, status, err ) ->
      ajaxFail( settings, req, status, err )
    .then ( json ) ->
      teams = App.util.collectify( json.resultSets[0].headers, json.resultSets[0].rowSet ).map ( t ) ->
        return App.util.cleanPropNames( t )
      return teams

  getTeamPlayers : ( id ) ->
    settings = ajaxSettings.eachTeam
    $.ajax
      type: "GET"
      url: settings.url
      data: $.extend {}, settings.data, { TeamID: id }
      contentType: "application/json"
      dataType: "jsonp"
    .fail ( req, status, err ) ->
      ajaxFail( settings, req, status, err )
    .then ( json ) ->
      players = App.util.collectify( json.resultSets[0].headers, json.resultSets[0].rowSet ).map ( t ) ->
        return App.util.cleanPropNames( t )
      return players 



  getPlayerShots : ( player ) ->

    data = $.extend( {}, ajaxSettings.shotChart.data, PlayerID: player.playerId )
    dfd = new $.Deferred

    $.ajax
      type: "GET"
      url: ajaxSettings.shotChart.url
      data: data
      contentType: "application/json"
      dataType: "jsonp"

    .fail ( req, status, err ) ->
      ajaxFail( settings, req, status, err )

    .then ( json ) ->
      worker = new Worker( "/scripts/binner.js" )
      startMessage = 
        "cmd": "start"
        "msg":
          "data" : json
          "binOpts" : $.extend( {}, App.league.binDims, { threshold: 4 } )
      worker.addEventListener 'message', ( event ) ->
        if event.data.type is "result"
          player.binnedShots = event.data.msg.bins
          dfd.resolve( player )
      , false
      worker.postMessage( startMessage )

    return dfd.promise()



  getLeagueShots : ( league ) -> 
    dfd = new $.Deferred
    $.getJSON "./data/raw-shooting-data.json"

    .fail ( req, status, err ) ->
      ajaxFail( settings, req, status, err )

    .then ( json ) ->
      startMessage =
        cmd: "start",
        msg:
          data : json,
          binOpts : App.binConfig
      worker = new Worker( "scripts/binner.js" )
      worker.addEventListener "message", ( event ) ->
        if event.data.type is "result"
          league.binnedShots = event.data.msg.bins
          league.unbinnedShots = event.data.msg.shots
          league.binDims = event.data.msg.dim
          dfd.resolve( league )
      , false
      worker.postMessage( startMessage )
    
    return dfd.promise()

  getLeagueSportVuData : ->
    dfd = new $.Deferred
    App.sportVu = []
    for set in ajaxSettings.sportVu
      do ( set = set ) ->
        $.getScript( set.url ).then ->
          App.sportVu.push $.extend( {}, window[set.varName] )
          window[set.varName] = undefined
          if App.sportVu.length is ajaxSettings.sportVu.length
            dfd.resolve( App.sportVu )

    return dfd.promise()
 
