window.App or= {}

retreived = 0
dfdRoster = new $.Deferred

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
      'PlayerID': '0'
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

ajaxFail = ( settings, req, status, err ) ->
  e = new Error "Ajax request to #{ settings.url } failed: #{ status }"
  e.status = status
  e.req = req
  e.originalError = err
  e.ajaxSettings = settings
  throw e

App.static or= {}

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

    req = $.ajax
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
      
      # retreived += 1
      # if retreived is 30 
      #   allPlayers = []
      #   for team in App.league.teams
      #     for player in team.players
      #       allPlayers.push( player )
      #   console.log allPlayers
      #   App.league.allPlayers = new App.Players allPlayers

        

    #   resolve( rosters ) if rosters.length is teamIds.length

    # resolve = ( rosters ) ->
    #   deferred.resolve new Collection _.flatten( for roster in rosters
    #     App.util.collectify( roster.resultSets[0].headers, roster.resultSets[0].rowSet )
    #   ).map ( t ) ->
    #     return App.util.cleanPropNames( t )      


  getPlayerShots : ( id ) ->
    settings = ajaxSettings.shotChart

    $.ajax
      type: "GET"
      url: settings.url
      data: $.extend {}, settings.data, { PlayerID: id }
      contentType: "application/json"
      dataType: "jsonp"
    .fail ( err ) ->
      ajaxFail( settings, req, status, err )
    .then ( json ) ->
      shots = App.util.collectify( json.resultSets[0].headers, json.resultSets[0].rowSet ).map ( t ) ->
        return App.util.cleanPropNames( t )
      return shots 


