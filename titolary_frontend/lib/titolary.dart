import 'package:admob_flutter/admob_flutter.dart';
import 'package:titolary/login_page.dart';
import 'package:titolary/services/login_service.dart';
import 'package:titolary/services/onpage_service.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:titolary/pages/loading_page.dart';
import 'package:titolary/pages/splash_page.dart';
import 'package:titolary/pages/error_page.dart';
import 'package:titolary/menu_page.dart';


class Titolary extends StatefulWidget {
  const Titolary({ Key key }) : super(key: key);
  _TitolaryState createState() => _TitolaryState();
}


class _TitolaryState extends State<Titolary> with WidgetsBindingObserver{
  
  final _loginService = LoginService();
  final _onpageService = OnPageService();

  @override
  void initState() {
    super.initState();
    //FirebaseAdMob.instance.initialize(appId: 'manz');
    Admob.initialize( 'manz' );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    super.didChangeAppLifecycleState(state);
    switch (state){
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.suspending:
        _onpageService.putUserOffline(_loginService);
        return;
      case AppLifecycleState.resumed:
        print("cececececececececececececece");
        _onpageService.putUserOnline(_loginService);
        return;
    }
  }

 @override
  Widget build(BuildContext context) {

    //provo ad ascoltare lo stato qui
    //var ss = new ServerService();
    //ss.currentServerStatus(new Duration(seconds: 10),10);

    return MaterialApp(
      title: 'Titolary',
      theme: ThemeData(
        fontFamily: 'RobotoSlab',
        primarySwatch: Colors.green,
      ),
      home: ChangeNotifierProvider(
        builder: (_) => _loginService,
        child: Consumer(
          builder:(context, LoginService ls, child){
            switch (ls.status) {
              case LoginStatus.Unauthenticated: return LoginPage();
              case LoginStatus.Authenticating: return LoadingPage();
              case LoginStatus.ErrorAuthenticating: return ErrorPage();
              case LoginStatus.Authenticated:
                _onpageService.putUserOnline(_loginService);
                return MenuPage();
              default: return SplashPage();
            }
          }
        )
      ),
      debugShowCheckedModeBanner: false,
    );
  }


}