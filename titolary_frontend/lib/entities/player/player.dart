
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titolary/entities/player/player_widget.dart';
import 'package:titolary/entities/source_value_pair.dart';
import 'package:recase/recase.dart';

class Player{
  String _name;
  String _team;
  String _role;
  String _id;
  List<SourceValuePair> _starting = new List<SourceValuePair>() ;

  String get id => this._id;
  String get name => this._name;
  String get team => (new ReCase(this._team)).titleCase;
  String get role => this._fullRole();
  List<SourceValuePair> get starting => this._starting;



  Player(String id, String name, String team, String role){
    this._id = id;
    this._name = name;
    this._team = team;
    this._role = role;
  }

  String _fullRole(){
    switch(this._role){
      case 'P': return 'Portiere';
      case 'D': return 'Difensore';
      case 'C': return 'Centrocampista';
      case 'A': return 'Attaccante';
      default: throw 'Role Unknow!';
    }
  }

  addStarting(List<dynamic> source){
    this._starting.add(
      new SourceValuePair(source[0], source[1])
    );
  }

  toString(){
    return this._name + "["+_role+"]" +"(" + this._team + ")" + _starting.toString();
  }

  Map<String,dynamic> toMap(){
    return {
      'id': this._id,
      'role': this._role
    };
  }

  Widget toWidget(bool isFavourite){
    return PlayerWidget(key: UniqueKey(), player:this);
  }

}