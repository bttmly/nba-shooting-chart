App.binConfig =
  dim1 : "x"
  dim2 : "y"
  dim1size : 10
  dim2size : 10
  threshold : 20

App.league = new App.League()
App.league.getLeagueSportVuData()
App.league.getLeagueShots().then ( league ) ->
  App.drawD3 league.unbinnedShots

App.league.getLeagueTeams().then ->
  league = arguments[0]
  league.teams.each ( team ) ->
    team.getTeamPlayers().then ->
      # App.fns.buildPlayerList()