//import 'package:chat_application/views/signin.dart';
import 'package:chat_application/views/signUp.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;
  void toggleView(){
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    /*if(showSignIn){
      return SignIn(toggleView);
    }else{
      return SignUp(toggleView);
    }*/
    //We don't need SignIn screen
    return SignUp(toggleView);
  }
}
