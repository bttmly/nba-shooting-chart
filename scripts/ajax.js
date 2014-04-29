// Generated by CoffeeScript 1.7.1
(function() {
  var ajaxFail, ajaxSettings;

  window.App || (window.App = {});

  ajaxSettings = {
    allTeams: {
      url: "http://stats.nba.com/stats/leaguedashteamstats",
      data: {
        'Season': '2013-14',
        'AllStarSeason': '',
        'SeasonType': 'Regular Season',
        'LeagueID': '00',
        'MeasureType': 'Base',
        'PerMode': 'PerGame',
        'PlusMinus': 'N',
        'PaceAdjust': 'N',
        'Rank': 'N',
        'Outcome': '',
        'Location': '',
        'Month': '0',
        'SeasonSegment': '',
        'DateFrom': '',
        'DateTo': '',
        'OpponentTeamID': '0',
        'VsConference': '',
        'VsDivision': '',
        'GameSegment': '',
        'Period': '0',
        'LastNGames': '0',
        'GameScope': '',
        'PlayerExperience': '',
        'PlayerPosition': '',
        'StarterBench': ''
      }
    },
    eachTeam: {
      url: "http://stats.nba.com/stats/commonteamroster/",
      data: {
        'Season': '2013-14',
        'LeagueID': '00',
        'TeamID': ''
      }
    },
    shotChart: {
      url: "http://stats.nba.com/stats/shotchartdetail",
      data: {
        'Season': '2013-14',
        'SeasonType': 'Regular Season',
        'LeagueID': '00',
        'TeamID': '0',
        'GameID': '',
        'Outcome': '',
        'Location': '',
        'Month': '0',
        'SeasonSegment': '',
        'DateFrom': '',
        'DateTo': '',
        'OpponentTeamID': '0',
        'VsConference': '',
        'VsDivision': '',
        'Position': '',
        'RookieYear': '',
        'GameSegment': '',
        'Period': '0',
        'LastNGames': '0',
        'ContextFilter': '',
        'ContextMeasure': 'FG_PCT',
        'zone-mode': 'basic'
      }
    },
    lineups: {
      url: "http://stats.nba.com/stats/leaguedashlineups",
      data: {
        'Season': '2013-14',
        'SeasonType': 'Regular Season',
        'LeagueID': '00',
        'TeamID': '',
        'MeasureType': 'Base',
        'PerMode': 'PerGame',
        'PlusMinus': 'N',
        'PaceAdjust': 'N',
        'Rank': 'N',
        'Outcome': '',
        'Location': '',
        'Month': '0',
        'SeasonSegment': '',
        'DateFrom': '',
        'DateTo': '',
        'OpponentTeamID': '0',
        'VsConference': '',
        'VsDivision': '',
        'GameSegment': '',
        'Period': '0',
        'LastNGames': '0',
        'GroupQuantity': '5',
        'GameScope': '',
        'PlayerExperience': '',
        'PlayerPosition': '',
        'StarterBench': '',
        'pageNo': '1',
        'rowsPerPage': '0'
      }
    },
    sportVu: [
      {
        url: "http://stats.nba.com/js/data/sportvu/speedData.js",
        varName: "speedData"
      }, {
        url: "http://stats.nba.com/js/data/sportvu/touchesData.js",
        varName: "touchesData"
      }, {
        url: "http://stats.nba.com/js/data/sportvu/passingData.js",
        varName: "passingData"
      }, {
        url: "http://stats.nba.com/js/data/sportvu/defenseData.js",
        varName: "defenseData"
      }, {
        url: "http://stats.nba.com/js/data/sportvu/reboundingData.js",
        varName: "reboundingData"
      }, {
        url: "http://stats.nba.com/js/data/sportvu/drivesData.js",
        varName: "drivesData"
      }, {
        url: "http://stats.nba.com/js/data/sportvu/catchShootData.js",
        varName: "catchShootData"
      }, {
        url: "http://stats.nba.com/js/data/sportvu/pullUpShootData.js",
        varName: "pullUpShootData"
      }, {
        url: "http://stats.nba.com/js/data/sportvu/shootingData.js",
        varName: "shootingData"
      }
    ]
  };

  ajaxFail = function(settings, req, status, err) {
    var e;
    e = new Error("Ajax request to " + settings.url + " failed: " + status);
    e.status = status;
    e.req = req;
    e.originalError = err;
    e.ajaxSettings = settings;
    throw e;
  };

  App.ajax = {
    getLeagueTeams: function() {
      var settings;
      settings = ajaxSettings.allTeams;
      return $.ajax({
        type: "GET",
        url: settings.url,
        data: settings.data,
        contentType: "application/json",
        dataType: "jsonp"
      }).fail(function(req, status, err) {
        return ajaxFail(settings, req, status, err);
      }).then(function(json) {
        var teams;
        teams = App.util.collectify(json.resultSets[0].headers, json.resultSets[0].rowSet).map(function(t) {
          return App.util.cleanPropNames(t);
        });
        return teams;
      });
    },
    getTeamPlayers: function(id) {
      var settings;
      settings = ajaxSettings.eachTeam;
      return $.ajax({
        type: "GET",
        url: settings.url,
        data: $.extend({}, settings.data, {
          TeamID: id
        }),
        contentType: "application/json",
        dataType: "jsonp"
      }).fail(function(req, status, err) {
        return ajaxFail(settings, req, status, err);
      }).then(function(json) {
        var players;
        players = App.util.collectify(json.resultSets[0].headers, json.resultSets[0].rowSet).map(function(t) {
          return App.util.cleanPropNames(t);
        });
        return players;
      });
    },
    getPlayerShots: function(player) {
      var data, dfd;
      data = $.extend({}, ajaxSettings.shotChart.data, {
        PlayerID: player.playerId
      });
      dfd = new $.Deferred;
      $.ajax({
        type: "GET",
        url: ajaxSettings.shotChart.url,
        data: data,
        contentType: "application/json",
        dataType: "jsonp"
      }).fail(function(req, status, err) {
        return ajaxFail(settings, req, status, err);
      }).then(function(json) {
        var startMessage, worker;
        worker = new Worker("/scripts/binner.js");
        startMessage = {
          "cmd": "start",
          "msg": {
            "data": json,
            "binOpts": $.extend({}, App.league.binDims, {
              threshold: 4
            })
          }
        };
        worker.addEventListener('message', function(event) {
          if (event.data.type === "result") {
            player.binnedShots = event.data.msg.bins;
            return dfd.resolve(player);
          }
        }, false);
        return worker.postMessage(startMessage);
      });
      return dfd.promise();
    },
    getLeagueShots: function(league) {
      var dfd;
      dfd = new $.Deferred;
      $.getJSON("./data/raw-shooting-data.json").fail(function(req, status, err) {
        return ajaxFail(settings, req, status, err);
      }).then(function(json) {
        var startMessage, worker;
        startMessage = {
          cmd: "start",
          msg: {
            data: json,
            binOpts: App.binConfig
          }
        };
        worker = new Worker("scripts/binner.js");
        worker.addEventListener("message", function(event) {
          if (event.data.type === "result") {
            league.binnedShots = event.data.msg.bins;
            league.unbinnedShots = event.data.msg.shots;
            league.binDims = event.data.msg.dim;
            return dfd.resolve(league);
          }
        }, false);
        return worker.postMessage(startMessage);
      });
      return dfd.promise();
    },
    getLeagueSportVuData: function() {
      var dfd, set, _fn, _i, _len, _ref;
      dfd = new $.Deferred;
      App.sportVu = [];
      _ref = ajaxSettings.sportVu;
      _fn = function(set) {
        return $.getScript(set.url).then(function() {
          App.sportVu.push($.extend({}, window[set.varName]));
          window[set.varName] = void 0;
          if (App.sportVu.length === ajaxSettings.sportVu.length) {
            return dfd.resolve(App.sportVu);
          }
        });
      };
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        set = _ref[_i];
        _fn(set);
      }
      return dfd.promise();
    }
  };

}).call(this);
