import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart';



class SplashScreen extends StatefulWidget {
  static String splash = "splash";

  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _mockCheckForSession().then(
        (response) {
          if(response) {
            navigateToHomeScreen();
          }
        }
    );
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 3000), () {} );
    return true;
  }

  void navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen()
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset("assets/imgs/test.png")
          ],
        ),
      ),
    );
  }

}