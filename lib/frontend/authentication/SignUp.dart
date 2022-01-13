import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loader_overlay/src/overlay_controller_widget_extension.dart';
import 'package:my_note/backend/auth_methods.dart';
import 'package:my_note/frontend/authentication/authentication_buttons.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUp();
  }
}

class _SignUp extends State<SignUp> {
  bool _showPassword = true;
  bool _isLoaderVisible = false;
  final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();
  TextEditingController confirmPasswordText = TextEditingController();

  Future<bool> doSignUp() async {
    FormState? formdata = formKey.currentState;
    if (formdata!.validate()) {
      try {
        context.loaderOverlay.show();
        setState(() {
          _isLoaderVisible = context.loaderOverlay.visible;
        });

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailText.text, password: passwordText.text);
        await registerNewUser(userEmail: emailText.text);
        if (_isLoaderVisible) {
          context.loaderOverlay.hide();
        }
        setState(() {
          _isLoaderVisible = context.loaderOverlay.visible;
        });

        return true;
      } catch (e) {
        print("=== Error: $e ===");
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    margin: EdgeInsets.only(top: 35.0, bottom: 20.0),
                    child: Hero(
                      tag: "app icon",
                      child: Image.asset(
                        "assets/images/AppIcon.png",
                      ),
                    ),
                  ),
                  authTextField(
                      labelText: "Email",
                      validator: (text) {
                        if (text!.isEmpty) {
                          return 'This Field is required';
                        } else if (!emailRegex.hasMatch(text.toString())) {
                          return "Invalid Email!";
                        } else if (text.endsWith(" ")) {
                          return "Delete the empty space";
                        }
                        return null;
                      },
                      textEditingController: emailText),
                  authTextField(
                      labelText: 'Password',
                      validator: (text) {
                        if (text!.isEmpty) {
                          return 'This Field is required';
                        } else if (text.length < 6) {
                          return "Passwords must be at least 6 characters ";
                        }
                        return null;
                      },
                      textEditingController: passwordText,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        child: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black,
                        ),
                      ),
                      showPassword: _showPassword),
                  authTextField(
                    labelText: 'Coonfirm Password',
                    validator: (text) {
                      if (text != passwordText.text) {
                        return "Passwords are not the same ";
                      }
                      return null;
                    },
                    textEditingController: confirmPasswordText,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      child: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black,
                      ),
                    ),
                    showPassword: _showPassword,
                  ),
                  Container(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        authWiteEmailButton(
                          buttonRole: 'Sign Up',
                          onPressed: () async {
                            var result = await doSignUp();
                            if (result) {
                              Navigator.of(context)
                                  .pushReplacementNamed("HomePage");
                            } else {
                              if (_isLoaderVisible) {
                                context.loaderOverlay.hide();
                              }
                              setState(() {
                                _isLoaderVisible =
                                    context.loaderOverlay.visible;
                              });
                              print('Error : sign up with email not compleat');
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Error happen"),
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          },
                        ),
                        VerticalDivider(
                          color: Colors.grey,
                          thickness: 1.5,
                          width: 10,
                        ),
                        authWiteGoogleButton(
                            onPressed: () async {
                              context.loaderOverlay.show();
                              setState(() {
                                _isLoaderVisible =
                                    context.loaderOverlay.visible;
                              });
                              bool result = await signInWithGoogle();

                              await registerNewUser(
                                  userEmail: FirebaseAuth
                                      .instance.currentUser!.email
                                      .toString());
                              if (_isLoaderVisible) {
                                context.loaderOverlay.hide();
                              }
                              setState(() {
                                _isLoaderVisible =
                                    context.loaderOverlay.visible;
                              });

                              if (result) {
                                Navigator.of(context)
                                    .pushReplacementNamed("HomePage");
                              } else {
                                print(
                                    'Error : sign up with google not compleat');
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Error happen"),
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            },
                            context: context)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            height: 55,
            color: Colors.tealAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Do you have an account?",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed("LogIn");
                  },
                  child: Text('Log in',
                      style: Theme.of(context).textTheme.bodyText1!),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
