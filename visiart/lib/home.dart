import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:visiart/signUp/signup.dart';
import 'package:visiart/customFormUser/userInterests.dart';

class HomeScreen extends StatefulWidget {
  static String home = "home";

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomeScreen> {

  var routes = <String, WidgetBuilder> {
    "/": (BuildContext context) => HomeScreen(),
    "/go": (BuildContext context) => UserInterestsScreen(),
    "/new": (BuildContext context) => SignUpScreen()
  };

  void _navigateToSignUpScreen() {
    //Navigator.pushNamed(context, '/new');
    Navigator.pushReplacement(
      context, MaterialPageRoute(
            builder: (BuildContext context) => SignUpScreen() )
    );
  }

  void _navigateToUserInterestsScreen() {
    //Navigator.pushNamed(context, '/go');
    Navigator.push(
      context, MaterialPageRoute(
        builder: (BuildContext context) => UserInterestsScreen() )
    );
  }

  @override
  Widget build(BuildContext context) {

    final emailField = TextField(
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final passwordField = TextField(
      obscureText: true,
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Mot de passe",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        onPressed: () { _navigateToUserInterestsScreen(); },
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
             height: 250,
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
                       child: Text("Visiart", style: TextStyle(color: Colors.white, fontSize: 60)),
                     ),
                   ),
                 ),
                 Positioned(
                   child: Container(
                     padding: EdgeInsets.only(top: 100),
                     child: Align(
                       alignment: Alignment.center,
                       child: Text("Mettez de l'ART dans vos vies", style: TextStyle(color: Colors.white, fontSize: 20)),
                     ),
                   ),
                 ),
               ],
             ),
           ),
           Container(
             color: Colors.white,
             child: Padding(
               padding: const EdgeInsets.all(20.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: <Widget>[
                   SizedBox(height: 20.0),
                   emailField,
                   SizedBox(height: 20.0),
                   passwordField,
                   SizedBox(height: 15.0),
                   loginButon,
                 ],
               ),
             ),
           ),
           Padding(
             padding: EdgeInsets.all(20),
             child: RichText(
               text: TextSpan(
                 children: [
                   TextSpan(
                     text: 'Pas encore inscrit ? Rejoignez les passionnés !',
                     style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
                     recognizer: TapGestureRecognizer()
                       ..onTap = () {
                         _navigateToSignUpScreen();
                       },
                   ),
                 ],
               ),
             ),
           ),
         ],
        ),
      ),
    );
  }
}