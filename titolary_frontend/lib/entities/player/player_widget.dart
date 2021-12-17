import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:titolary/entities/player/player.dart';
import 'package:titolary/entities/team_match.dart';
import 'package:titolary/services/database_service.dart';

import '../source_value_pair.dart';

class PlayerWidget extends StatefulWidget{
  Player _player;

  PlayerWidget({@required Key key, @required Player player}): super(key:key){
    this._player = player;
  }
  
  @override
  State<StatefulWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget>{

  bool _playerIsFavourite;
  TeamMatch _teamMatch;
  int _normalizer;


  @override
  void initState(){
    super.initState();

    this._playerIsFavourite = false;
    DatabaseService.isPlayerPrefered(widget._player).then(
      (isFavourite){ 
        if(this.mounted){setState((){
          this._playerIsFavourite = isFavourite;
        });}
      }
    );

    this._teamMatch = TeamMatch.placeholder();
    DatabaseService.getTeamsMatch(widget._player.team.toUpperCase()).then(
      (matchCorrispondente){ 
        if(this.mounted){setState(() {
          this._teamMatch = matchCorrispondente;
        });}
      }
    );

    this._normalizer = 1;
    DatabaseService.getBestAndWorseSpan().then(
      (span){
        if(this.mounted){setState(() {
          this._normalizer = span;
        });}
      }
    );
    

  }



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:[
          Expanded(
            flex: 4,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(
                  _buildPlayerName(widget._player.name),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Text(widget._player.team),
                Text(widget._player.role)
              ],
            ),
              
          ),

          Expanded(
            flex: 3,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:_getStartingSemaphore(widget._player.starting)
              ),
            )
          ),

          Expanded(
            flex: 3,
            child: _getMatchAsText()
          ),

          Expanded(
            flex: 1,
            child: Column(
              children:[
                _getButtonForPreference(),
                SizedBox(height: 25,)
              ]
            )
          ),
        ]
      )
    );
  }

  ButtonTheme _getButtonForPreference(){
    return ButtonTheme(
      height: 30,
      child:FlatButton(
        focusColor: Colors.transparent,
        hoverColor : Colors.transparent,
        highlightColor: Colors.transparent,
        color: Colors.transparent,
        splashColor: Colors.green[100],
        shape: CircleBorder(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        
        child: Text(
          'P',
          style: _playerIsFavourite ? 
            TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.green[800]
            ) 
            : 
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black38
            )
        ),
        onPressed: _handlePreference
      )
    );
  }

  void _handlePreference() async {
    if(this._playerIsFavourite){
      DatabaseService.removePlayerFromPrefered(widget._player);
    }else{
      DatabaseService.addPlayerToPrefered(widget._player);
    }
    setState((){
      this._playerIsFavourite = !this._playerIsFavourite;
    });
  }

  String _buildPlayerName(String originalName){
    var separatedName = originalName.split(' ');
    if(separatedName.length > 1){
      separatedName.removeAt(0);
    }
    ReCase playrName = new ReCase(separatedName.join(' '));
    return playrName.titleCase;
  }

  List<Row> _getStartingSemaphore(List<SourceValuePair> _starting){
    List<Row> semaphore = [];
    for(SourceValuePair svp in _starting){
      semaphore.add(
        Row(
          children:[
            Container(
              height: 10,
              width: 10,
              decoration: new BoxDecoration(
                color: svp.value ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 4,
            ),
            Text(svp.source.name)
          ]
        )
      );
    }
    return semaphore;
  }

  Widget _getMatchAsText(){
    if(this._teamMatch.getPoints().reduce( (sq1, sq2)=> sq1+sq2) == 0){
      // se entrambe le squadre sono a zero vuol dire che
      // non ho ancora inizializzato partita
      return Text('');
    }else{
      double vantaggio = (((this._teamMatch.getPoints()[0] - this._teamMatch.getPoints()[1]) / this._normalizer ) + 1) * 5;
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87
          ),
          children: <TextSpan>[
            TextSpan(text: 'vs '),
            TextSpan(text: this._teamMatch.opponent, style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: this._teamMatch.house ? " in casa.":" fuori casa."),
            TextSpan(text: '\n'),
            TextSpan(text: 'Ind. Vantaggio: ', style: TextStyle(fontSize: 13)),
            TextSpan(text: vantaggio.toStringAsPrecision(2) ),
          ],
        ),
      );
    }
  }

}