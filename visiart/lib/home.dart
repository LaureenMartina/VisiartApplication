import 'dart:ui';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static String home = "home";

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      alignment: Alignment.center,
                      height: 60,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: Offset(3, 3)
                          )
                        ]
                      ),
                      child: Text('Se Connecter', style: TextStyle(color: Colors.white, fontSize: 20.0)),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Ah pas encore Membre ? Viens nous rejoindre !", style: TextStyle(color: Colors.blue, fontSize: 15, fontStyle: FontStyle.italic))
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