
import 'package:requests/requests.dart';
import 'package:titolary/entities/player/player.dart';
import 'package:query_params/query_params.dart';

class DataFetchService{
  static final String domain = "https://otherservices.justtitlesplease.com/titolary";
  static final String playersPath  = "/v1/players_from_hint";
  static final String teamPath     = "/v1/teams_from_hint";
  static final String preferedPath = "/v1/prefered";
  static final String calendarPath = "/v1/calendar";
  static final String leaderboardPath  = "/v1/leaderboard";
  
  static Future<dynamic> getRequestProxy(String url) async {
    print('#-# GET PROXY #-#');
    print('>> ' + url + ' <<');
    var resp = await Requests.get(url);
    print('>> ' + resp.json()['message'] + ' <<');
    assert(resp.json()['status'] == 200);
    print('#-# GET PROXY #-#');
    return resp.json()['data'];
  }

  static Future<List<Player>> getTeamHint(String userId, String teamHint) async {
    int len = teamHint.length;
    teamHint = teamHint.toLowerCase();

    var data = await DataFetchService.getRequestProxy(
      domain + teamPath + "?uid=$userId&thint=$teamHint&many=$len");

    return parseData(data as List<dynamic>);
  }

  static Future<List<Player>> getPlayersHint(String userId, String playerHint) async {
    int len = playerHint.length;
    playerHint = playerHint.toLowerCase();

    var data = await DataFetchService.getRequestProxy(
      domain + playersPath + "?uid=$userId&phint=$playerHint&many=$len");

    return parseData(data as List<dynamic>);
  } 
  
  static Future<List<Player>> getPrefered(String userId, List<String> playerIds) async {
    URLQueryParams queryParams = new URLQueryParams();
    queryParams.append('uid', userId);

    var data = await DataFetchService.getRequestProxy(
      domain + preferedPath + "?" + queryParams.toString() + "&" + encodeArray(playerIds, 'prefs') );
      
    return parseData(data as List<dynamic>);
  } 


  static Future<List<dynamic>> getCalendar(String userId) async {
    return (await DataFetchService.getRequestProxy(
      domain + calendarPath + "?uid=$userId")
    ) as List<dynamic>;
  }

  static Future<List<dynamic>> getLeaderboard(String userId) async {
    return (await DataFetchService.getRequestProxy(
      domain + leaderboardPath + "?uid=$userId")
    ) as List<dynamic>;
  }




  static List<Player> parseData(dynamic data){
    List<Player> players = new List();
    for(var player_data in data){  
      var p = new Player(
        player_data['_id'],
        player_data['player']['name'],
        player_data['team']['name'],
        player_data['role']
      );
      
      for( var start in player_data['starting'])
        p.addStarting(start);

      players.add(p);
    }
    return players;
  }

  static String encodeArray(List<String> array, String paramName){

    if(array.length == 0) return "";
    
    String enc = "";
    for(int i = 0; i<array.length; i++){
      enc += paramName + '['+ i.toString() + ']=' +array[i] + '&';
    }
    return enc.substring(0, enc.length-1);

  }

}