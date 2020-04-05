import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:visiart/home.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {

    final nameField = Container(
      height: 40,
      child: TextField(
        obscureText: true,
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
        decoration: InputDecoration(
            icon: Icon(Icons.person),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            hintText: "Nom / Pseudo",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );

    final emailField = Container(
      height: 40,
      child: TextField(
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
        decoration: InputDecoration(
            icon: Icon(Icons.email),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            hintText: "Email",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );

    final passwordField = Container(
      height: 40,
      child: TextField(
        obscureText: true,
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
        decoration: InputDecoration(
            icon: Icon(Icons.lock),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            hintText: "Mot de passe",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );

    final createAccountButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        onPressed: () {},
        child: Text("GO !",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0).copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/imgs/pattern.png'),
                    fit: BoxFit.fill
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: Container(
                      child: Center(
                        child: Text("Créer un Compte", style: TextStyle(color: Colors.white, fontSize: 30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    nameField,
                    SizedBox(height: 20.0),
                    emailField,
                    SizedBox(height: 20.0),
                    passwordField,
                    SizedBox(height: 15.0),
                    createAccountButon,
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Ou créer un compte avec :',
                      style: TextStyle(color: Colors.black87),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          HomeScreen();
                        },
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Image.asset("assets/imgs/gmail.png"),
                  iconSize: 50,
                  tooltip: 'link to Gmail',
                  onPressed: () {},
                ),
                IconButton(
                  icon: Image.asset("assets/imgs/fb.png"),
                  iconSize: 50,
                  tooltip: 'link to Facebook',
                  onPressed: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );

  }
}
