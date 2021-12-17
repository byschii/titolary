import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';

class APageWithAds extends StatelessWidget {

  Widget content;
  String bannerId;

  APageWithAds({@required Widget content, @required String bannerId}) : 
    this.content = content, this.bannerId = bannerId;


  @override
  Widget build(BuildContext context) {

    Widget adPart = Container(
      //height: 10,
      padding: EdgeInsets.symmetric(
        vertical: 1,
        horizontal: 1
      ),
      color: Colors.blueAccent,
      child: AdmobBanner(

        adUnitId: this.bannerId,
        adSize: AdmobBannerSize.BANNER,
      )
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      verticalDirection: VerticalDirection.down,
      children: <Widget>[
        Expanded(
          child: content,
        ),
        // adPart
      ],
    );
  }
}