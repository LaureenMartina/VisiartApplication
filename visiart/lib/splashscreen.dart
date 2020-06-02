import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkDurationTimer().then(
        (response) {
          if(response) {
            navigateToHomeScreen();
          }
        }
    );
  }

  Future<bool> _checkDurationTimer() async {
    await Future.delayed(Duration(milliseconds: 3000), () {} );
    return true;
  }

  void navigateToHomeScreen() {
    Navigator.pushNamed(context, 'connexion');
    /*Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen()
        )
    );*/
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