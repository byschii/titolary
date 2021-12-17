import 'package:firebase_database/firebase_database.dart';
import 'package:titolary/entities/team_match.dart';
import 'package:titolary/services/data_fetch_service.dart';
import 'package:titolary/services/database_service.dart';

import 'login_service.dart';

class OnPageService{
  FirebaseDatabase _fbDatabase = FirebaseDatabase.instance;

  Future putUserOnline(LoginService ls) async {
    /**
     * volgio fare in modo che incrementi anche un contatore
     * per vedere che sta piu tempo on line
     */


    if(ls.status == LoginStatus.Authenticated){
      DatabaseReference _userCollection = this._fbDatabase.reference().child("users");
      _userCollection.child(
        ls.user.uid
        ).set({ "uptime": DateTime.now()/*.toUtc()*/.toString()} );

      this.updateCalendarData(ls);
    }
  }


  Future updateCalendarData(LoginService ls) async{
    var matches = await Future.wait([
      DataFetchService.getCalendar(ls.user.uid),
      DataFetchService.getLeaderboard(ls.user.uid)
    ]);

    print(matches[0]);
    print(':::::::::::::::');
    List<TeamMatch> newCalendarTableContent = [];
    var calendar = matches[0];
    var leaderboard = matches[1];

    for(var team in leaderboard){
      for(var match in calendar){        
        print(match);
        if( team['name'] == match['home']['name']){ // vuol dire che gioca in casa
          newCalendarTableContent.add(TeamMatch(
            team['name'],
            team['logo'],
            match['away']['name'],
            true,
            DateTime.parse(match['date'])
          ));
          continue;
        }

        if( team['name'] == match['away']['name']){ // vuol dire che gioca in casa
          newCalendarTableContent.add(TeamMatch(
            team['name'],
            team['logo'],
            match['home']['name'],
            false,
            DateTime.parse(match['date'])
          ));
          continue;
        }
      }
    }

    for(var match in newCalendarTableContent ){
      var teamp = leaderboard.where( (l)=> l['name'] == match.team ).toList()[0]['points'];
      var oppop = leaderboard.where( (l)=> l['name'] == match.opponent ).toList()[0]['points'];
      match.insertPoints(team:teamp, opponent:oppop);
    }
    
    DatabaseService.updateCalendar(newCalendarTableContent);
    
  }



  Future putUserOffline(LoginService ls) async {
    /**
     * volgio fare in modo che cavi solo il suo uptime
     * non tutta la pagina dell utente
     */
    if(ls.status == LoginStatus.Authenticated){
      DatabaseReference _userCollection = this._fbDatabase.reference().child("users");
      _userCollection.child(
        ls.user.uid
        ).remove();
    }
  }
}