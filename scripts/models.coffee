window.App or= {}

class Model
  constructor : ( model ) ->
    for key, val of model
      this[key] = val

App.League = class League extends Model
  getLeagueTeams : ->
    App.ajax.getLeagueTeams().then ( teams ) =>
      this.teams = new Teams( teams )
      return this

  getLeaguePlayerData : ->
    App.ajax.getLeaguePlayerData()

  getLeagueShots : ->
    App.ajax.getLeagueShots( this )

  getLeagueSportVuData : ->
    App.ajax.getLeagueSportVuData()

  drawLeagueShootingChart : ->
    if this.binnedShots
      App.drawChart( this.binnedShots )
    else
      throw new Error "League has no shots to chart."


App.Team = class Team extends Model
  getTeamPlayers : ->
    App.ajax.getTeamPlayers( this.teamId ).then ( players ) =>
      this.players = new Players( players )
      App.fns.buildPlayerList()
      return this

App.Player = class Player extends Model
  getPlayerShots : ->      
    App.ajax.getPlayerShots( this )

  drawShootingChart : ->
    if this.binnedShots
      App.drawChart( this.binnedShots )
    else
      throw new Error "Player has no shots to chart."


App.Shot = class Shot extends Model


App.Teams = class Teams extends Collection
  constructor : ( models ) ->
    col = ( new Team( model ) for model in models )
    super( col )

App.Players = class Players extends Collection
  constructor : ( models ) ->
    col = ( new Player( model ) for model in models )
    super( col )

App.Shots = class Shots extends Collection
  constructor : ( models ) ->
    col = ( new Shot( model ) for model in models )
    super( col )

