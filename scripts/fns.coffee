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

      html = "<select id='player-select' class='player-select'>"
      App.allPlayers.each ( p ) ->
        html += "<option value='#{ p.playerId }'>#{ p.name }</option>"
      html += "</select>"

      $select = $( html )
      .prependTo $ "body"
      .on "change", ( event ) ->
        console.log this.value
        player = App.allPlayers.findWhere( playerId : parseInt( this.value, 10 ) )
        player.getPlayerShots().then ( player ) ->
          player.drawShootingChart()

