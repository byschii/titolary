import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titolary/services/data_fetch_service.dart';
import 'package:titolary/services/database_service.dart';
import 'package:titolary/services/login_service.dart';

import 'app_title.dart';
import 'entities/player/player.dart';
import 'entities/team_match.dart';

class PreferedPage extends StatefulWidget {
  @override
  _PreferedPageState createState() => _PreferedPageState();  
}

class _PreferedPageState extends State<PreferedPage> {

  List<Player> players = [];

  Future _getPreferedPlayerData() async {
    String uid = Provider.of<LoginService>(context).user.uid;

    List<String> databaseIds =await DatabaseService.getPreferedPlayersId();
    if(databaseIds.length >= 1){
      print(databaseIds);
      this.players = await DataFetchService.getPrefered(uid, databaseIds);
    }

  }



  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child:AppTitle.getTitle(),
            alignment: Alignment.center
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            child:FutureBuilder(
              future: TeamMatch.getChampionshipDayBegining(),
              builder: (context,snap) => snap.data == null ? Text('') : snap.data as RichText
            ),
          ),
          Expanded(
            child:FutureBuilder(
              future: _getPreferedPlayerData(),
              builder: (ctx, snap)=> players.length != 0 ? 
              
              Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5 ),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(11)
                ),
                child:ListView.separated(
                  
                  shrinkWrap:true, 
                  itemCount: players.length,
                  itemBuilder: (context,index) => players[index].toWidget(true),

                  separatorBuilder: (context, index) => Divider(
                    color: Theme.of(context).primaryColor,
                    thickness: 3,
                    height: 3,
                    
                  )
                )
              )
              :
              Container(
                width: 280,
                child: Center(
                  child:Text(
                    "Vai nelle altre sezioni e premi la 'P' vicina ai giocatori per aggiungerli ai preferiti..",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20
                    ),
                  )
                )
              )
              
            )
          ),
          Container( // il menu sotto
            height: 55,
            margin: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 10 ),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor, width: 2),
              borderRadius: BorderRadius.circular(11)
            ),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: "Elimina preferiti",
                  child:FlatButton(
                    shape: CircleBorder(),
                    focusColor: Colors.transparent,
                    hoverColor : Colors.transparent,
                    highlightColor: Colors.transparent,
                    color: Colors.transparent,
                    splashColor: Colors.green[100],
                    child: Icon( Icons.delete),
                    onPressed: (){
                      DatabaseService.dropFavourite();
                      setState((){this.players = [];});
                    },
                  )
                )
              ]
            )
          )
        ]
      )
    );
  }
}