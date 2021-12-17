import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:titolary/entities/player/player.dart';
import 'package:titolary/entities/team_match.dart';



class DatabaseService{

  static const String DB_NAME = 'titolary.db';
  static const String PREFS_TABLE_NAME = 'PREFERENCE';
  static const String CALENDAR_TABLE_NAME = 'CALENDAR';

  //static Future<Database> _database;

  static Future<Database> database() async {
    var dbPath = await getDatabasesPath();
    var dbFullPath = join(dbPath, DB_NAME );
    
    return openDatabase(dbFullPath,
      onOpen: (db){
        db.execute('''
          create table if not exists $PREFS_TABLE_NAME (
            id TEXT PRIMARY KEY, role STRING
          );
          ''');

        db.execute('''
          create table if not exists $CALENDAR_TABLE_NAME (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            team_name TEXT,
            team_logo TEXT,
            leaderboard_points NUMBER,
            opponent_team_name TEXT,
            opponent_leaderboard_points NUMBER,
            is_home BOOLEAN,
            match_datetime DATETIME
          );
          ''');
      },
      version: 1);
  }

  static Future<int> addPlayerToPrefered(Player p) async {
    Database db = await database();
    return await db.insert(PREFS_TABLE_NAME, p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<bool> isPlayerPrefered(Player p) async {
    Database db = await database();
    var selected = await db.query(PREFS_TABLE_NAME, where:'id = \'${p.id}\'' );

    return selected.length != 0;
  }

  static Future<int> removePlayerFromPrefered(Player p) async {
    Database db = await database();
    return await db.delete(PREFS_TABLE_NAME, where:'id = \'${p.id}\'' );
  }

  static Future<List<String>> getPreferedPlayersId() async {
    Database db = await database();
    List<Map<String, dynamic>> selection = await db.query(PREFS_TABLE_NAME);
    List<String> plIds = selection.map( (Map<String, dynamic> row) => row['id'].toString() ).toList();
    return plIds;
  }

  static Future getPreferedPlayersIdV2() async {
    Database db = await database();
    return await db.query(PREFS_TABLE_NAME);
  }

  static Future dropFavourite() async {
    Database db = await database();
    int deleted = await db.delete(PREFS_TABLE_NAME);
    print('deleted $deleted rows');
  }

  static void updateCalendar(List<TeamMatch> newCalendarTableContent) async {
    Database db = await database();
    await db.delete(CALENDAR_TABLE_NAME);
    for(var match in newCalendarTableContent){
      db.insert(CALENDAR_TABLE_NAME, match.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<TeamMatch> getTeamsMatch(String teamName) async {
    Database db = await database();
    var data = await db.query(CALENDAR_TABLE_NAME, where: "team_name = \'$teamName\' ");
    if(data == null){
      return TeamMatch.placeholder();
    }
    var matchData = data[0];
    return TeamMatch.fromMap(matchData);
  }

  static Future<List<TeamMatch>> getAllMatches() async {
    Database db = await database();
    var matchData = await db.query(CALENDAR_TABLE_NAME);
    return matchData.map( (map) => TeamMatch.fromMap(map)  ).toList();
  }

  static Future<int> getBestAndWorseSpan() async {
    Database db = await database();
    var matchData = await db.query(CALENDAR_TABLE_NAME);
    var result = matchData.map( (Map<String, dynamic> match) => TeamMatch.fromMap(match) ).toList();    
    result.sort(
      (TeamMatch match1, TeamMatch match2 ) => match1.points - match2.points
    );

    return (result.first.points - result.last.points).abs();
  }

  static Future cose() async {
    Database db = await database();
    for( var match in await db.query(CALENDAR_TABLE_NAME)){
      print(TeamMatch.fromMap(match).toString());
    }
  }

}