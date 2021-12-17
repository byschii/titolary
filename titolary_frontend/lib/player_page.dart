import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titolary/app_title.dart';
import 'package:titolary/entities/team_match.dart';
import 'package:titolary/services/data_fetch_service.dart';
import 'package:titolary/services/database_service.dart';
import 'package:titolary/services/login_service.dart';


class PlayerPage extends StatefulWidget {
  PlayerPage({Key key}) : super(key: key);

  @override
  _PlayerPage createState() => _PlayerPage();
}

class _PlayerPage extends State<PlayerPage> {
  List players = [];

  bool inputIsEmpty = true;

  Widget mainContent;



  @override
  Widget build(BuildContext context) {
    
    mainContent = inputIsEmpty
                  ?
                  Container(
                    width: 280,
                    child: Center(
                      child:Text(
                        "Cerca un giocatore scrivendo il nome nel campo sotto..",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20
                        ),)
                      )
                    )
                  :
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5 ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(11)
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      shrinkWrap:true, 
                      itemCount: players.length,
                      itemBuilder: (context,index) => FutureBuilder<bool>(
                        future: DatabaseService.isPlayerPrefered(players[index]),
                        builder: (c,s) => players[index].toWidget(s.data)
                      ),
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.green,
                        thickness: 3,)
                      
                    )
                  );

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
              child:mainContent,
            ),
            Container( // player
              height: 55,
              margin: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 10 ),
              child: TextField(
                onChanged: (player) async {
                  setState(() {
                    inputIsEmpty = (player.length == 0); 
                  });
                  if(player.length >= 3){
                    String userId = Provider.of<LoginService>(context).user.uid;
                    var playerHints = await DataFetchService.getPlayersHint(userId, player);
                    setState(() {
                      players = playerHints;
                    });
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 26
                  ),
                  labelText: "Giocatore"
                ),
                style: TextStyle(
                  fontSize: 21
                ),
              ),
            ),            
          ],
        ),
      );
  }
}