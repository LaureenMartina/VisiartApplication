import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class HomeScreen extends StatefulWidget {
  static String home = "home";

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/imgs/pattern.png'),
                    fit: BoxFit.fill
                ),
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('VisiArt', style: TextStyle(color: Colors.black, fontSize: 60)),
                ),
              ],
            ),
            Container(
              height: 50.0,
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
              ),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFF05A22),
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          "Connexion",
                          style: TextStyle(
                            color: Color(0xFFF05A22),
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pas encore membre ? Rejoinez notre Team !',
                          style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
                          recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launch('https://docs.flutter.io/');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

/*
Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 10, top: 10),
                    child: Container(
                      alignment: Alignment.center,
                      height: 60,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      child: Text('Facebook', style: TextStyle(color: Colors.white, fontSize: 20.0)),
                    ),
                  ),
                )
 */