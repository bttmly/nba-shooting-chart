window.App or= {}

App.fns =

  buildPlayerList : ->  
    if App.league.teams.every( "players" )
      App.allPlayers = []
      for team in App.league.teams
        for player in team.players
          player.name = player.player
          App.allPlayers.push( player )
      App.allPlayers = new Collection( App.allPlayers )

      htmlStr = "<select id='player-select' class='player-select'>"
      App.allPlayers.each ( p ) ->
        htmlStr += "<option value='#{ p.playerId }'>#{ p.name }</option>"
      htmlStr += "</select>"

      $select = $( htmlStr )
      .prependTo $ "body"
      .on "change", ( event ) ->
        player = App.allPlayers.findWhere( playerId : +this.value )
        player.getPlayerShots().then ( player ) ->
          player.drawShootingChart()

