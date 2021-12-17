import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:titolary/a_page_with_ads.dart';
import 'package:titolary/nice_bottom_bar.dart';
import 'package:titolary/player_page.dart';
import 'package:titolary/prefered_page.dart';
import 'package:titolary/services/ads_ids_service.dart';
import 'package:titolary/team_page.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  int _pageIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:_getPagesWithIndex(_pageIndex),
      bottomNavigationBar: NiceBottomBar(
        showElevation: true,
        selectedIndex: _pageIndex,
        items: _getBottomIcons(), 
        onItemSelected: (index) {
          setState(() { _pageIndex = index; });
        },
      )
    );
  }


  List<NiceBottomBarItem> _getBottomIcons(){
    return [
      NiceBottomBarItem(
        icon: Icon(FontAwesomeIcons.userAlt),
        title: Text("Singolo"),
        activeColor: Colors.green
      ),
      NiceBottomBarItem(
        icon: Icon(FontAwesomeIcons.users),
        title: Text("Squadra"),
        activeColor: Colors.green
      ),
      NiceBottomBarItem(
        icon: Icon(Icons.star),
        title: Text('Preferiti'),
        activeColor: Colors.green
      )
    ];
  }

  Widget _getPagesWithIndex(int index){
    switch(index){
      case 0: return APageWithAds(
        content: PlayerPage(),
        bannerId: AdsIdsService.getBanner(1)
      );
      case 1: return APageWithAds(
        bannerId: AdsIdsService.getBanner(2),
        content: TeamPage()
      );
      case 2: return APageWithAds(
        bannerId: AdsIdsService.getBanner(1),
        content: PreferedPage(),
      );
      default:
        throw "no page with this index";
      }    
    } 
}