import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:firebase_core/firebase_core.dart';

enum LoginStatus{
  Unauthenticated,
  Authenticating,
  ErrorAuthenticating,
  Authenticated 
}

class LoginService extends ChangeNotifier{
  // questa app deve 
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  LoginStatus _status;
  FirebaseUser _user;
  
  //Future<FirebaseUser> get user async => await _firebaseAuth.currentUser();
  FirebaseUser get user => this._user;
  LoginStatus get status => _status;
  
  LoginService(){
    _firebaseAuth.onAuthStateChanged.listen( _whenStateChange );
  }

  Future _whenStateChange(FirebaseUser authenticatingUser ) async {
    this._user = authenticatingUser;
    if(_user == null) _status = LoginStatus.Unauthenticated;
    else _status = LoginStatus.Authenticated;
    
    notifyListeners();
    await Future.delayed(Duration.zero);
  }

  Future signInWithMailAndPsw(String email, String password) async {
    this._status = LoginStatus.Authenticating;
    notifyListeners();

    AuthResult result;
    try{
      result = await this._firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password );
    }catch(exception, _){
      result = await this._firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password );
    }

    this._user = result.user;
    this._status = LoginStatus.Authenticated;
    notifyListeners(); 
  }

  Future signIn() async {
    this._status = LoginStatus.Authenticating;
    notifyListeners();
    try{
      await _signInWithGoogle(); // qui vene messo LoginStatus.Authenticated
    }catch(exception,stackTrace){
      this._status = LoginStatus.ErrorAuthenticating;
      print(exception);
      print(stackTrace);
    }
  }

  Future signOut() async{
    this._firebaseAuth.signOut();
    this._status = LoginStatus.Unauthenticated;
    notifyListeners();
    this._user = null;
    await Future.delayed(Duration.zero);
  }

  Future _signInWithGoogle() async {
    try{
            print("#############################");
      print("#############################");
      GoogleSignInAccount _googleUser = await _googleSignIn.signIn();
            print("#############################");

      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;

      print("#############################");
      print("#############################");

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: _googleAuth.accessToken,
        idToken: _googleAuth.idToken
      );

      final AuthResult result = await _firebaseAuth.signInWithCredential(credential);
      this._user = result.user;

      assert(this._user != null);
      assert(this._user.uid != null);
      this._status = LoginStatus.Authenticated;
      notifyListeners(); 
    }catch(e,st){
      print('>>>>>>>>>>>>>>>>>>>>>');
      print(e);
      print('>>>>>>>>>>>>>>>>>>>>>');
      print(st);
      print('>>>>>>>>>>>>>>>>>>>>>');

      this._status = LoginStatus.ErrorAuthenticating;
      notifyListeners(); 
    }
  }

}