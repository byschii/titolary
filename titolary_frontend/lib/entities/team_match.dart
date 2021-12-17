import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titolary/services/database_service.dart';

class TeamMatch{
  String _teamName;
  String _teamLogo;
  int _leaderboardPoints;
  String _opponentTeamName;
  int _opponentLeaderboardPoints;
  bool _isHome;
  DateTime _matchDatetime;

  String get team => this._teamName;
  String get opponent => this._opponentTeamName;
  bool get house => this._isHome;
  int get points => this._leaderboardPoints;

  TeamMatch(
    String teamName,
    String teamLogo,
    String opponentTeamName,
    bool isHome,
    DateTime matchDatetime
  ){
    this._teamName = teamName;
    this._teamLogo = teamLogo;
    this._opponentTeamName = opponentTeamName;
    this._isHome = isHome;
    this._matchDatetime = matchDatetime;
  }

  TeamMatch.placeholder(){
      this._teamName = "";
      this._teamLogo = "";
      this._leaderboardPoints = 0;
      this._opponentTeamName = "";
      this._opponentLeaderboardPoints = 0;
      this._isHome = false;
      this._matchDatetime = null;
  }

  TeamMatch.fromMap(Map<String,dynamic> sqlResult){
      this._teamName = sqlResult['team_name'];
      this._teamLogo = sqlResult['team_logo'];
      this._leaderboardPoints = sqlResult['leaderboard_points'];
      this._opponentTeamName = sqlResult['opponent_team_name'];
      this._opponentLeaderboardPoints = sqlResult['opponent_leaderboard_points'];
      this._isHome = sqlResult['is_home'] == 1;
      this._matchDatetime = DateTime.parse(sqlResult['match_datetime']);
  }

  Map<String,dynamic> toMap(){
    return {
      'team_name':this._teamName ,
      'team_logo':this._teamLogo ,
      'leaderboard_points':this._leaderboardPoints ,
      'opponent_team_name':this._opponentTeamName ,
      'opponent_leaderboard_points':this._opponentLeaderboardPoints ,
      'is_home':this._isHome ,
      'match_datetime':this._matchDatetime.toString()
    };
  }

  void insertPoints({@required int team, @required int opponent}){
      this._leaderboardPoints = team;
      this._opponentLeaderboardPoints = opponent;
  }

  List<int> getPoints(){
    return [this._leaderboardPoints, this._opponentLeaderboardPoints];
  }

  @override
  String toString() {
    var team = _teamName + "(" + this._leaderboardPoints.toString() +")";
    var opponent = _opponentTeamName + "(" + this._opponentLeaderboardPoints.toString() +")";
    var casa = "[" + (_isHome ? "in home":"away" ) + "]";

    return team + " - " + opponent + casa + " : " + this._matchDatetime.toLocal().toString()  ;
  }

  static Future<RichText> getChampionshipDayBegining() async{
    List<TeamMatch> championshipDay = await DatabaseService.getAllMatches();
    championshipDay.sort(
      (tm1, tm2) => tm1._matchDatetime.difference(tm2._matchDatetime).inHours
    );
    
    DateTime begining = championshipDay[0]._matchDatetime;
    
    print(championshipDay);
    print('---------');
    var today =DateTime.now();
    if(begining.isBefore( today )){
      return RichText(
        text:TextSpan(
          text:"Le squadre stanno già giocando",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87
          ),
        )
      );
    }

    String intToDay(int day){
      switch (day) {
        case 1: return "LUNEDÌ";
        case 2: return "MARTEDÌ";
        case 3: return "MERCOLEDÌ";
        case 4: return "GIOVEDÌ";
        case 5: return "VENERDÌ";
        case 6: return "SABATO";
        case 7: return "DOMENICA";
        default:
          throw "Unknown day";
      }

    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87
        ),
        children: <TextSpan>[
          TextSpan(text: 'Ricorda che giocano '),
          TextSpan(text: intToDay(begining.weekday )),
          TextSpan(text: ' alle '),
          TextSpan(text: begining.hour.toString()),
          TextSpan(text: ':'),
          TextSpan(text: begining.minute == 0 ? '00' : begining.minute.toString()),

        ],
      ),
    );
  }


}