window.NBA = do ->

  # private
  responseFlags =
    lineups : false
    players : false
    teams   : false

  class Player extends Backbone.Model
  
    # call this to retreive the shooting data for an individual player
    # sets the player's "SHOTS" attribute to a Shots collection with the returned data.
    getPlayerShootingData : ->      
      ajax = NBA.settings.shotChartAjax
      data = $.extend {}, ajax.data, 
        PlayerID: this.get( "PLAYER_ID" )
        TeamID: 0
      $.ajax
        type: "GET"
        url: ajax.url
        data: data
        contentType: "application/json"
        dataType: "jsonp"
        done: ( json ) ->
          console.log "SHOOTING DATA SUCCESS"
        fail: ( err ) ->
          console.log err
      .then ( json ) =>
        shots = NBA.collectify( json.resultSets[0].headers, json.resultSets[0].rowSet )
        this.set
         "SHOTS": new NBA.Collections.Shots shots

        console.log "shot:"
        console.log shots

        # NBA.pushArray( NBA.raw.shots, shots )

    # returns a Lineups collection with all of the lineups this player is in.
    getLineups : ->
      unless NBA.bb.lineups.length
        return false
      
      playerId = this.get( "PLAYER_ID" )
      return new NBA.Collections.Lineups NBA.bb.lineups.filter ( lineup ) ->
        return lineup.get( "PLAYER_IDS" ).indexOf( playerId ) > 0

    # returns the Team model for this player's team
    getTeam : ->
      return NBA.bb.teams.findWhere 
        TEAM_ID: this.get( "TeamID" )



  class Players extends Backbone.Collection
  
    model: Player
    initialize : ( models ) ->

    byName : ( playerName ) ->
      return this.findWhere { PLAYER: playerName }

    # grab a Player model by the PLAYER_ID attribute
    byPlayerId : ( playerId ) ->
      return this.findWhere { PLAYER_ID: playerId }

    # grab a the Player models that match an array of player Ids.
    # optionally, pass true as the second argument to get a Players collection instead
    byPlayerIdArray : ( playerIdArray, returnCollection ) ->
      
      collection = this
      results = for playerId in playerIdArray
        collection.byPlayerId( playerId )

      return if returnCollection then new NBA.Collections.Players( results ) else results

  class Shot extends Backbone.Model
  class Shots extends Backbone.Collection
    model : Shot
    initialize : ( models ) ->

  class Team extends Backbone.Model
    initialize : ->

    # sets the "ROSTER" attribute to a Players collection of the team's players
    # also sets the "ABBR" attribute, which isn't returned in the team data JSON
    setPlayers : ->
      this.set "ROSTER", new NBA.Collections.Players NBA.bb.players.where
        TeamID: this.get( "TEAM_ID" )
      this.set "ABBR", this.get("ROSTER").at(0).get("TEAM_ABBREVIATION")


    # sets the "LINEUPS" attribute to a Lineups collection of the team's lineups
    setLineups : ->
      team = this
      team.set "LINEUPS", new NBA.Collections.Lineups NBA.bb.lineups.where
        TEAM_ABBREVIATION: this.abbr

    # gets the shooting data for an entire team, then sets the "SHOTS" attribute on each player as appropriate. 
    # JSON response is fairly large ( ~1-2MB ) so use with caution
    getTeamShootingData : ->
      team = this
      ajax = NBA.settings.shotChartAjax
      data = $.extend ajax.data,
        PlayerID: 0
        TeamID: team.get( "TEAM_ID" )    

      $.ajax
        type: "GET"
        url: ajax.url
        data: data
        jsonpCallback: "jsonpCallback"
        contentType: "application/json"
        dataType: "jsonp"
        success: ( json ) ->
          # nothing here for now.
        fail: ( err ) ->
          console.log err
      .then ( json ) ->
        teamShots = NBA.collectify json.resultSets[0].headers, json.resultSets[0].rowSet
        playerIds = _.uniq _.pluck teamShots, "PLAYER_ID"
        playerModels = NBA.bb.players.byPlayerIdArray( playerIds )
        playerModels.forEach ( player ) ->
          player?.set "SHOTS", new NBA.Collections.Shots _.where teamShots, { PLAYER_ID: player.get("PLAYER_ID") }

        # NBA.pushArray( NBA.raw.shots, teamShots )

  class Teams extends Backbone.Collection
    model : Team
    initialize : ( models ) ->

    # calls .setPlayers() on each team in the collection
    setAllPlayers : ->
      this.each ( team ) ->
        team.setPlayers()

    setAllLineups : ->
      this.each ( team ) ->
        team.setLineups()


  class Lineup extends Backbone.Model
    initialize: ->

  class Lineups extends Backbone.Collection
    model : Lineup
    initialize : ( models ) ->

  Models:
    Player: Player
    Shot: Shot
    Team: Team
    Lineup: Lineup

  Collections:
    Players: Players
    Shots: Shots
    Teams: Teams
    Lineups: Lineups

  Views: {}
  Routers: {}
  
  Hub: new Backbone.Wreqr.EventAggregator()

  raw :
    shots : {}

  # these hold the Backbone collections
  bb:
    teams :   []
    players : []
    lineups : []
    shots :   []

  settings :

    # data for general team data JSONP request.
    allTeamsAjax:
      url: "http://stats.nba.com/stats/leaguedashteamstats"
      callback: "jsonpCallback"
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
        # 'callback': 'jsonpCallback'

    # data for team roster JSONP requests.
    eachTeamAjax:
      url : "http://stats.nba.com/stats/commonteamroster/"
      callback: "jsonpCallback"
      data:
        'Season': '2013-14'
        'LeagueID': '00'
        'TeamID': ''
        # 'callback': 'NBA.oneTeamJsonpCallback'

    # data for shot chart JSONP requests.
    shotChartAjax:
      url: "http://stats.nba.com/stats/shotchartdetail"
      callback: "jsonpCallback"
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

    # data for lineup JSONP requests.
    lineupAjax :
      url: "http://stats.nba.com/stats/leaguedashlineups"
      callback: "jsonpCallback"
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
        # 'callback': 'NBA.lineupJsonpCallback'

    # sportsVu data files
    # these are regular JS files so we can load them with $.getScript and not worry about cross-domain issues (yay)
    nbaData : 
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

  init: ->

    # build the events hub that will be used to sequence AJAX requests.
    NBA.buildHub()

    
    NBA.getTeamData()
    # NBA.retreiveLocalRosters()



  setup: ->

    NBA.bb.players = new NBA.Collections.Players( NBA.raw.players )
    
    NBA.bb.teams.setAllPlayers()
    NBA.bb.teams.setAllLineups()

    actualPlayers = NBA.bb.players.reject ( p ) ->
      return !p.get( "PTS" )

    topTen = _.sortBy( actualPlayers, ( p ) ->
      return p.get( "PTS" )
    ).reverse().slice(0, 10).map ( p ) ->
      return p.get( "PLAYER" )

    console.log topTen

    window.randomStar = NBA.bb.players.findWhere { PLAYER: NBA.pickRandom( topTen ) }
    window.randomStar.getPlayerShootingData()

    
  # This event hub controls the sequence of AJAX requests 
  buildHub: ->
    NBA.Hub
    .on "allTeamDataDone", ( data ) ->
      responseFlags.allTeams = true
      console.log "allTeamDataDone"
      console.log data

    .on "eachTeamDataDone", ( data ) ->
      responseFlags.eachTeam = true

    .on "playerDataDone", ( data ) ->
      responseFlags.players = true

    .on "lineupDataDone", ( data ) ->
      responseFlags.lineups = true

  # the pattern for AJAX requests and responses is to process the data in the deffered.then() function
  # rather than in a callback, primarily to keep things grouped logically
  # after the data is processed, trigger an event on the event hub
  #
  # this is the first AJAX request.
  # it returns data about each team, including averages for most team satistics
  # this data is used for two things:
  #   - constructing Team models and the Teams collection
  #   - getting a list of TEAM_ID that will be used in requests for detailed roster data
  getTeamData: ->
    ajax = NBA.settings.allTeamsAjax
    $.ajax
      type: "GET"
      url: ajax.url
      data: ajax.data
      jsonpCallback: "jsonpCallback"
      contentType: "application/json"
      dataType: "jsonp"
    .fail ( jqXHR, textStatus, errorThrown ) ->
      console.log "getRosterData( #{teamId} ) AJAX error:"
      console.log errorThrown
    .then ( json ) ->

      # this was previously a separate function, but it seems to make sense to just parse out the returned team data here
      # builds the main Teams collection we'll be using

      teams = NBA.collectify json.resultSets[0].headers, json.resultSets[0].rowSet
      NBA.teamLookup = for team in teams
        name : team.TEAM_NAME
        id : team.TEAM_ID
      NBA.bb.teams = new NBA.Collections.Teams( teams )

      # trigger the allTeamDataDone event on the hub, passing an array of team Id
      # this event will then call NBA.getRosterData with the passed data
      
      # event architechture not working as expected.
      NBA.Hub.trigger( "allTeamDataDone" )

      # call this from event hub once I figure that out
      NBA.getRosterData( NBA.bb.teams.pluck( "TEAM_ID" ) )

  processTeamData: ( data ) ->

    teams = NBA.collectify data.resultSets[0].headers, data.resultSets[0].rowSet

    NBA.teamLookup = for team in teams
      name : team.TEAM_NAME
      id : team.TEAM_ID

    NBA.bb.teams = new NBA.Collections.Teams teams

    NBA.getRosterData( NBA.bb.teams.pluck "TEAM_ID" )


  getRosterData: ( teamIds ) ->
    
    # teamIds = NBA.bb.teams.pluck( "TEAM_ID" )

    rosters = []
    ajax = NBA.settings.eachTeamAjax

    # let jQuery make up a random parameter for jsonpCallback
    # using the same function for each leads to errors
    for teamId in teamIds
      do ->
        $.ajax
          type: "GET"
          url: ajax.url
          data: $.extend {}, ajax.data, { TeamID: teamId }
          # jsonpCallback: "jsonpCallback"
          contentType: "application/json"
          dataType: "jsonp"
        .fail ( jqXHR, textStatus, errorThrown ) ->
          console.log "getRosterData( #{teamId} ) AJAX error:"
          console.log errorThrown
        .then ( json ) ->
          rosters.push( json )

          # proceed once all requests are finished
          if rosters.length is teamIds.length

            # build a vanilla collection ( NOT Backbone ) of player data. 
            # We'll successively extend these as we gather detailed SportsVU data.
            # after which we'll create a Backbone collection
            NBA.raw.players = _.flatten( for roster in rosters
              NBA.collectify( roster.resultSets[0].headers, roster.resultSets[0].rowSet )
            )


            # maybe something for later...
            # the roster data returned here also has data on the team's coaching staff


            # again, this should be called from the event hub rather than here
            NBA.getDetailedPlayerData()

  # might want to revive this in the future
  # retreiveLocalRosters : ( url ) ->
  #   $.getJSON "data/rosters.json", ( data ) ->
  #     NBA.ROSTERS = data

  #     NBA.processRosters( data )

  # requests SportsVU player tracking data from NBA.com
  # each dataset is a regular .js file that sets a variable equal to the data
  getDetailedPlayerData : ->
    completedDataRequests = 0
    NBA.settings.nbaData.forEach ( data ) ->
      $.getScript data.url, ( res ) ->
        
        # increment so we can track where we are
        completedDataRequests++

        # hit this function every time we get data back
        processData( data.varName )

        # once we have all the scripts we can proceed
        if completedDataRequests is NBA.settings.nbaData.length

          # could build the Players collection right here...
          cleanData()

          # again, this should be called from the event hub
          NBA.getLineups()

    # call this every time we get a script back
    # since the scripts are evaluated in the global scope, we their variables will be attached to window
    # the variable names are stored in nbaData alongside the url
    # in processData() we grab the variable and mash the data on to the vanilla player objects
    processData = ( varName ) ->
      headers = window[varName].resultSets[0].headers
      window[varName].resultSets[0].rowSet.forEach (player) ->
        s = _.object(headers, player)
        s.PLAYER_ID = parseInt(s.PLAYER_ID)
        playerObj = _.findWhere NBA.raw.players,
          PLAYER_ID: s.PLAYER_ID
        playerObj = _.extend(playerObj, s) if playerObj

    # cleans up some data attributes to make them easier to work with.
    # any future manipulation of basic player data should be done here
    cleanData = ->
      NBA.raw.players.forEach ( p ) ->
        [feet, inches] = p.HEIGHT.split "-"
        p.HEIGHT = parseInt( feet ) * 12 + parseInt( inches )
        p.BIRTH_DATE = new Date p.BIRTH_DATE
        for key, val of p
          if p.hasOwnProperty( key )
            unless isNaN parseFloat( val )
              p[key] = parseFloat( val )
            # if _.isNumber( val )
            #   p[key] = Math.round( val * 100000 ) / 100000
        return

  # gets a 
  getLineups : ->
    ajax = NBA.settings.lineupAjax
    req = $.ajax
      type: "GET"
      url: ajax.url
      data: ajax.data
      contentType: "application/json"
      dataType: "jsonp"
      success: ( json ) ->
        # nothing here
    .fail ( jqXHR, textStatus, errorThrown ) ->
      console.log "getLineups() AJAX error:"
      console.log errorThrown
    .then ( json ) ->

      # manipulate some lineup data attributes to make them easier to work with
      lineups = NBA.collectify json.resultSets[0].headers, json.resultSets[0].rowSet
      lineups.forEach ( l ) ->
        l.PLAYER_IDS = l.GROUP_ID.split( " - " ).map(Number)
        players = l.GROUP_NAME.split( " - " )
        l.PLAYER_NAMES = []
        players.forEach ( p ) ->
          l.PLAYER_NAMES.push p.split( "," ).reverse().join( " " )

      NBA.bb.lineups = new NBA.Collections.Lineups lineups

      # DONE! ... with the setup AJAX

      NBA.setup()

  checkFlags : ->
    return responseFlags

  collectify : ( headers, arrays ) ->
    _.object( headers, array ) for array in arrays

  pushArray : ( target, toPush ) ->
    for el in toPush
      target.push( el )
    return target

  pickRandom : ( array ) ->
    index = Math.floor( Math.random() * array.length )
    if array.getBackboneClass is "Collection"
      return array.at( index )
    else
      return array[index]

$ ->

  NBA.init()


# https://github.com/bgrins/devtools-snippets/blob/master/snippets/console-save/console-save.js
do (console) ->
  console.save = (data, filename) ->
    unless data
      console.error "Console.save: No data"
      return
    filename = "console.json"  unless filename
    data = JSON.stringify(data, `undefined`, 4)  if typeof data is "object"
    blob = new Blob([data],
      type: "text/json"
    )
    e = document.createEvent("MouseEvents")
    a = document.createElement("a")
    a.download = filename
    a.href = window.URL.createObjectURL(blob)
    a.dataset.downloadurl = ["text/json", a.download, a.href].join(":")
    e.initMouseEvent "click", true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null
    a.dispatchEvent e


###
more NBA endpoints to explore:
http://stats.nba.com/stats/commonallplayers/?LeagueID=00&Season=2013-14&IsOnlyCurrentSeason=1&callback=playerinfocallback

http://stats.nba.com/stats/commonteamyears?LeagueID=00&callback=teaminfocallback

http://stats.nba.com/stats/commonplayerinfo/?PlayerID=201566&SeasonType=Regular+Season&LeagueID=00

http://stats.nba.com/stats/playerdashboardbygeneralsplits?Season=2013-14&SeasonType=Regular+Season&LeagueID=00&PlayerID=201566&MeasureType=Base&PerMode=PerGame&PlusMinus=N&PaceAdjust=N&Rank=N&Outcome=&Location=&Month=0&SeasonSegment=&DateFrom=&DateTo=&OpponentTeamID=0&VsConference=&VsDivision=&GameSegment=&Period=0&LastNGames=0
###