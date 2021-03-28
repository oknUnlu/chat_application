import 'package:chat_application/helper/helperfunctions.dart';
import 'package:chat_application/services/auth.dart';
import 'package:chat_application/services/database.dart';
import 'package:chat_application/views/chatroomscreen.dart';
import 'package:chat_application/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignIn extends StatefulWidget {
  final Function toggle;

  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passwordTextEditingController =
      new TextEditingController();

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  FToast fToast = FToast();
  final formKey = GlobalKey<FormState>();
  QuerySnapshot snapShotUserInfo;
  bool isLoading = false;
  String toastMessage, phoneNumberText;

  signInMe() async {
    if (formKey.currentState.validate()) {
      HelperFunction.saveUserEmailSharedPreference(
          emailTextEditingController.text);

      databaseMethods
          .getUserByUserEmail(emailTextEditingController.text)
          .then((val) {
        snapShotUserInfo = val;
        // ignore: deprecated_member_use
        HelperFunction.saveUserEmailSharedPreference(
            // ignore: deprecated_member_use
            snapShotUserInfo.documents[0].data()["email"]);
        // ignore: deprecated_member_use
        HelperFunction.saveUserNameSharedPreference(
            // ignore: deprecated_member_use
            snapShotUserInfo.documents[0].data()["name"]);
      });

      setState(() {
        isLoading = true;
      });

      await authMethods
          .signInWithEmailAndPassword(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((val) async {
        try {
          if (val.userId != null) {
            HelperFunction.saveUserLoggedInSharedPreference(true);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ChatRoom()));
          }
        } catch (e) {
          if (val == 'user-not-found') {
            toastMessage = 'No user found for that email.';
          } else if (val == 'wrong-password') {
            toastMessage = 'Wrong password provided for that user.';
          } else {
            toastMessage = 'Wrong password or userId.';
          }
          fToast.init(context);
          _showToast();
        }
      });
    }
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user.uid != null) {
        Map<String, String> userInfoMap = {
          "name": userCredential.user.displayName,
          "email": userCredential.user.email
        };
        HelperFunction.saveUserNameSharedPreference(userCredential.user.email);
        HelperFunction.saveUserEmailSharedPreference(
            userCredential.user.displayName);

        databaseMethods.uploadUserInfo(userInfoMap);
        HelperFunction.saveUserLoggedInSharedPreference(true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatRoom()));
      }
    } on FirebaseAuthException catch (e) {
      print(e.code.toString());
    }
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14.0,
          ),
          Text(toastMessage),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 50,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      IntlPhoneField(
                        countryCodeTextColor: Colors.white,
                        dropDownArrowColor: Colors.white,
                        decoration: textFieldInputDecoration('Phone Number'),
                        initialCountryCode: 'TR',
                        onChanged: (phone) {
                          phoneNumberText = phone.completeNumber;
                        },
                        style: simpleTextStyle(),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Please provide a valid email";
                          },
                          style: simpleTextStyle(),
                          controller: emailTextEditingController,
                          decoration: textFieldInputDecoration("email")),
                      SizedBox(
                        height: 4,
                      ),
                      TextFormField(
                          obscureText: true,
                          style: simpleTextStyle(),
                          controller: passwordTextEditingController,
                          decoration: textFieldInputDecoration("password")),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Forgot Password?",
                      style: simpleTextStyle(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                GestureDetector(
                    onTap: () {
                      signInMe();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            const Color(0xff007EF4),
                            const Color(0xff2A75BC)
                          ]),
                          borderRadius: BorderRadius.circular(30)),
                      child: Text(
                        "Sign In",
                        style: mediumTextStyle(),
                      ),
                    )),
                SizedBox(
                  height: 16,
                ),
                GestureDetector(
                    onTap: () {
                      signInWithGoogle();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: Text(
                        "Sign In with Google",
                        style: TextStyle(color: Colors.black87, fontSize: 17),
                      ),
                    )),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have account? ",
                      style: mediumTextStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.toggle();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Register now",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
