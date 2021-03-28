import 'package:chat_application/helper/helperfunctions.dart';
import 'package:chat_application/models/user.dart';
import 'package:chat_application/views/chatroomscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  HelperFunction helperFunction = new HelperFunction();
  String phoneNo, smsId, verificationId;

  // ignore: deprecated_member_use
  UserAuth _userFromUserCredential(UserCredential user) {
    return user != null ? UserAuth(userId: user.user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return _userFromUserCredential(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return e.code;
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return _userFromUserCredential(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return e.code;
    } catch (e) {
      print(e);
    }
  }

  //PhoneAuthentication---------------------------------------------------------
  // ignore: missing_return
  Future createUserWithPhone(String phone, BuildContext context) {
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 0),
        verificationCompleted: (AuthCredential authCredential) {
          _auth
              .signInWithCredential(authCredential)
              .then((UserCredential result) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ChatRoom()));
            return "OK";
          }).catchError((e) {
            return "error";
          });
        },
        verificationFailed: (FirebaseAuthException exception) {
          return "error";
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          final _codeController = TextEditingController();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text("Please Enter Verification Code"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[TextField(controller: _codeController)],
              ),
              actions: <Widget>[
                // ignore: deprecated_member_use
                FlatButton(
                  child: Text("Submit"),
                  textColor: Colors.white,
                  color: Colors.green,
                  onPressed: () {
                    // ignore: deprecated_member_use
                    var _credential = PhoneAuthProvider.getCredential(
                        verificationId: verificationId,
                        smsCode: _codeController.text.trim());
                    _auth
                        .signInWithCredential(_credential)
                        .then((UserCredential result) {
                      //Open chatRoomScreen
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => ChatRoom()));
                      return "OK";
                    }).catchError((e) {
                      return "error";
                    });
                  },
                )
              ],
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
        });
  }

  Future resetPass(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
