import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:my_note/app_theme.dart';
import 'package:my_note/frontend/authentication/LogIn.dart';
import 'package:my_note/frontend/authentication/SignUp.dart';
import 'package:my_note/frontend/notes_management/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    GlobalLoaderOverlay(
      child: MaterialApp(
        builder: EasyLoading.init(),
        home: userRegistration(),
        debugShowCheckedModeBanner: false,
        title: 'My Note',
        routes: {
          "SignUp": (context) => SignUp(),
          "LogIn": (context) => LogIn(),
          "HomePage": (context) => HomePage(),
          "WelcomeScreen": (context) => WelcomeScreen(),
        },
        theme: appTheme(),
      ),
    ),
  );
}

userRegistration() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return WelcomeScreen();
  } else {
    return HomePage();
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 5.0, right: 5.0),
            height: screenHeight / 1.9,
            width: screenWidth,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 15.0,
                  offset: Offset(0.5, -0.5),
                  spreadRadius: 1.0,
                )
              ],
              color: Colors.tealAccent,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                  tag: "app icon",
                  child: Image.asset(
                    "assets/images/AppIcon.png",
                  )),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 15),
                width: screenWidth,
                child:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? Text(
                            'My Note',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          )
                        : SizedBox(),
              ),
            ],
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              width: screenWidth,
              height: 55,
              color: Colors.tealAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed("LogIn");
                    },
                    child: Text(
                      "Log in",
                      style: Theme.of(context).textTheme.bodyText1!,
                    ),
                  ),
                  Text(
                    "Or",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed("SignUp");
                    },
                    child: Text(
                      "Sing up",
                      style: Theme.of(context).textTheme.bodyText1!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
