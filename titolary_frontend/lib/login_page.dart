import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:titolary/app_title.dart';
import 'package:titolary/services/login_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class LoginPage extends StatelessWidget {
  LoginPage({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Row(
        children: [
          Expanded(flex: 1, child: Container()),
          Expanded(flex: 5,
            child:Container(
              child:Column(
                children:[
                  SizedBox( height:50 ),
                  AppTitle.getTitle(),               
                  SizedBox(  height: 60, ),  
                  LoginEmailForm(),
                  SizedBox( height: 40, ),
                  MyLoginWithGoogleButton().build(context),
                  Expanded(
                    child:Container(
                      padding: EdgeInsets.only(bottom:15) ,
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Guarda, l'account mi serve solo per questioni tecniche. Non devo fare nessuna profilazione. E se proprio vuoi una scoreggia di tecnicismo, sappi che ci va di mezzo Firebase.",
                        style: TextStyle(
                          fontSize: 11
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ]
              )
            )
          ),
          Expanded(flex: 1, child: Container())
        ],
      )
    );
  }
}




class LoginEmailForm extends StatefulWidget{
  State<LoginEmailForm> createState() => _LoginEmailFormState();
}

class _LoginEmailFormState extends State<LoginEmailForm>{
  final _formKey = GlobalKey<FormState>();
  final double blocksSeparation = 10;
  final double blockHeight = 50;
  final double blocksFontSize = 18;

  String email;
  String password;
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key:_formKey,
      child: Column(
        children: <Widget>[
          Container(height: blockHeight, child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            onChanged: (email){
              setState(()=> this.email = email);
            },
            validator: (email){
              if(email != null && email.length > 0 )return null;
              else return "Dai, metti qualcosa..";
            },
            decoration:InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 1,
                horizontal: 5
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              prefixIcon: Icon(Icons.mail),
              labelText: "Email"
            ),
            style: TextStyle(
              fontSize: blocksFontSize
            )
          ),),
          SizedBox(height: blocksSeparation),
          Container(height: blockHeight, child: TextFormField(
            onChanged: (password){
              setState(() => this.password = password);
            },
            validator: (password){
              if(password != null && password.length > 0 )return null;
              else return "Dai, metti qualcosa..";
            },
            obscureText: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 1,
                horizontal: 5
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              prefixIcon: Icon(Icons.lock),
              labelText: "Password"
            ),
            style: TextStyle(
              fontSize: blocksFontSize
            ),
          ),),
          SizedBox(height: blocksSeparation),
          Container(height: blockHeight, child: FlatButton(
            onPressed: (){
              if(_formKey.currentState.validate()){
                print(this.email+" "+this.password);
                Provider.of<LoginService>(context).signInWithMailAndPsw(
                  this.email, this.password);
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
              side: BorderSide(
                color: Colors.green,
                width: 2
              ),
            ),
            color: Color.fromARGB(0, 0, 0, 0),
            child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[
              Icon(
                Icons.person_add,
                color: Colors.green,
              ),
              SizedBox( width: 5 ), 
              Text(
                "Accedi con la Mail",
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.green,
                  fontWeight: FontWeight.w600
                )
              )
            ]
          ),
          ),),
        ],
      ),
    );
  }
  
}


class MyLoginWithGoogleButton extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: FlatButton(
        autofocus: false,
        onPressed:()async{
          Provider.of<LoginService>(context).signIn();
        },
        child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            Icon(
              FontAwesomeIcons.google,
              color: Colors.red,
            ),
            SizedBox( width: 5 ), 
            Text(
              "Accedi con Google",
              style: TextStyle(
                fontSize: 18, 
                color: Colors.red,
                fontWeight: FontWeight.w600
              )
            )
          ]
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
          side: BorderSide(
            color: Colors.red,
            width: 2
          ),
        ),
        color: Color.fromARGB(0, 0, 0, 0),
      )
    );




  }
  
  }