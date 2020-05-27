import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:visiart/customFormUser/userInterests.dart';
import 'package:visiart/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:visiart/models/User.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:http/http.dart' as http;

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
                  onPressed: () {
                    signInWithGoogle().whenComplete(() {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return UserInterestsScreen();
                          },
                        ),
                      );
                    });
                  },
                ),
                IconButton(
                  icon: Image.asset("assets/imgs/fb.png"),
                  iconSize: 50,
                  tooltip: 'link to Facebook',
                  onPressed: () {

                  },
                ),
              ],
            )
          ],
        ),
      ),
    );

  }
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInWithGoogle() async {
  
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();

  var name = currentUser.displayName;
  var email = currentUser.email;
  var password = " "; // TODO if connexion is GMAIL

  User userModel = new User.fromUser(name, email);
  userModel.setUsername(name);
  userModel.setEmail(email);

  var json = createUser(name, name, email, password);
  print("json $json");

  /*SharedPref sharedPref = SharedPref();
  sharedPref.save("userId", userid);
  sharedPref.save("name", name);
  sharedPref.save("email", email);*/

  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

Future<Map<String, dynamic>> createUser(String newUsername, String newName, String newEmail, String newPassword) async {
  final api = 'http://91.121.165.149/auth/local/register';
  print("username: $newUsername");
  print("name: $newName");
  print("email: $newEmail");
  print("pwd: $newPassword");
  final response = await http.post(
      api,
      headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
          'username': newUsername,
          'name': newName,
          'email': newEmail,
          'password': newPassword
      }),
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    print('jsonResponse -> ${jsonResponse['id']}!');
    return jsonResponse;
  } else {
    throw Exception('Failed to load user from API');
  }
}

/*void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}*/