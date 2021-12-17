import 'package:flutter/material.dart';
import 'package:titolary/entities/source.dart';

class SourceValuePair{
  Source _source;
  bool _value;

  Source get source => _source;
  bool get value => _value;

  SourceValuePair(String source, bool value){
    this._source = Source.fromString(source);
    this._value = value;
  }

  @override
  String toString() {
    return "{"+_source.name+","+_value.toString()+"}";
  }

  Widget toWidget(){
    return Container(      
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      color: _value ? Colors.lightGreen : Color.fromARGB(170 , 240, 10, 10) ,
      child:Text(
        this._source.shortName,
        style: TextStyle(
          fontWeight: _value ? FontWeight.bold : FontWeight.normal ,
          fontSize: _value? 16 : 14
        )
      ));

  }

}