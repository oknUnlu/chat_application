import 'package:chat_application/helper/helperFunctions.dart';
import 'package:chat_application/services/auth.dart';
import 'package:chat_application/services/database.dart';
import 'package:chat_application/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController userNameTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();
  //TextEditingController emailTextEditingController = new TextEditingController();
  String phoneNumberText, countryText;

  bool isLoading = false;

  //FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  HelperFunction helperFunction = new HelperFunction();
  final formKey = GlobalKey<FormState>();

  //PhoneAuthentication---------------------------------------------------------
  // ignore: non_constant_identifier_names
  SignMeUp(String phoneNumber, BuildContext context) async {
    try {
      var result = await authMethods.createUserWithPhone(phoneNumber, context);
      // ignore: unrelated_type_equality_checks
      if (phoneNumber != "" || result != "error") {
        uploadUserInfo();
      } else {
        print("error");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // ignore: missing_return
  Future uploadUserInfo() {
    //HelperFunction.saveUserEmailSharedPreference(emailTextEditingController.text);
    HelperFunction.saveUserNameSharedPreference(userNameTextEditingController.text);
    HelperFunction.saveUserPhoneSharedPreference(phoneNumberText);
    HelperFunction.saveUserCountrySharedPreference(countryText);

    setState(() {
      isLoading = true;
    });

    Map<String, String> userInfoMap = {
      "name": userNameTextEditingController.text,
      //"email": emailTextEditingController.text,
      "phone": phoneNumberText
    };

    // ignore: unnecessary_statements
    databaseMethods.uploadUserInfo(userInfoMap);
    HelperFunction.saveUserLoggedInSharedPreference(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
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
                                countryText = phone.countryCode;
                              },
                              style: simpleTextStyle(),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            TextFormField(
                                validator: (val) {
                                  return val.isEmpty || val.length < 4
                                      ? "Please provide username"
                                      : null;
                                },
                                controller: userNameTextEditingController,
                                style: simpleTextStyle(),
                                decoration:
                                    textFieldInputDecoration("User Name")),
                          /*SizedBox(
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
                                controller: emailTextEditingController,
                                style: simpleTextStyle(),
                                decoration: textFieldInputDecoration("email")),*/
                            SizedBox(
                              height: 4,
                            ),
                            TextFormField(
                                obscureText: true,
                                validator: (val) {
                                  return val.length >= 8
                                      ? null
                                      : "Please provide password 8+ character";
                                },
                                controller: passwordTextEditingController,
                                style: simpleTextStyle(),
                                decoration:
                                    textFieldInputDecoration("Password")),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          if (phoneNumberText != null) {
                            SignMeUp(phoneNumberText, context);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please enter a phone number",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.redAccent,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          }
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
                            "Sign Up",
                            style:  mediumTextStyle(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      /*Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                          "Sign Up with Google",
                          style: TextStyle(color: Colors.black87, fontSize: 17),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: mediumTextStyle(),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.toggle();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "SignIn now",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ],
                      ),*/
                      SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
