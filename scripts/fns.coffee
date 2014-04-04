window.App or= {}

App.fns =

  buildPlayerList : ->  
    App.allPlayers = []
    for team in App.league.teams
      for player in team.players
        App.allPlayers.push( player )
    App.allPlayers = new Players( App.allPlayers )