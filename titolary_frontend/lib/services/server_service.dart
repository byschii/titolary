import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';


enum ServerStatus{
  Ready, Maintenance
}


class ServerService extends ChangeNotifier{
  RemoteConfig _remoteConfig;
  

  Future<String> getStateString() async {
    await this._remoteConfig.fetch(expiration: const Duration(minutes: 1));
    await this._remoteConfig.activateFetched();
    

    String status = this._remoteConfig.getString('server_status');
    return status;
  }


  // https://dart.dev/articles/libraries/creating-streams
  Stream<int> timedCounter(Duration interval, [int maxCount]) async* {
  int i = 0;
  while (true) {
    await Future.delayed(interval);
    yield i++;
    if (i == maxCount) break;
  }
}


  Future<void> currentServerStatus(Duration frequency, int times) async {
    this._remoteConfig = await RemoteConfig.instance;
    for (int i = 1; i <= times; i++) {
      await Future.delayed(frequency);
      
      print("############");
      print(await this.getStateString());
      print("############");

    }
  }


}