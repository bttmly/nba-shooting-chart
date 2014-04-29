App.league = new App.League()
App.league.getLeagueSportVuData()
App.league.getLeagueShots().then ( league ) ->
  console.log league.unbinnedShots
  App.drawD3 league.unbinnedShots
