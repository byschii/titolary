import 'package:flutter/material.dart';

class AppTitle{
  static Widget getTitle(){
    return Text("Titolary",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'Pacifico',
        fontSize: 45,
        letterSpacing: 2,
        //backgroundColor: Colors.red
      ),
    );
  }
}