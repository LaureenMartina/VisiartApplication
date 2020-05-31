import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart';
import 'package:visiart/customFormUser/userInterests.dart';
import 'package:visiart/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:visiart/models/User.dart';
import 'package:visiart/config/SharedPref.dart';

SharedPref sharedPref = SharedPref();
User userModel = new User();
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();


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
                  icon: Image.asset("assets/icons/gmail.png"),
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
                  icon: Image.asset("assets/icons/fb.png"),
                  iconSize: 50,
                  tooltip: 'link to Facebook',
                  onPressed: () {
                    displayIdFromSharedPrefs();
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

Future<String> signInWithGoogle() async {
  
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  //assert(user.email != null);
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();

  var name = currentUser.displayName;
  var email = currentUser.email;
  var password = " "; // TODO empty if connexion is GMAIL

  createUser(name, name, email, password);

  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

 // ------ Get value from SharedPreferences ------
void displayIdFromSharedPrefs() async {
  var _id = await sharedPref.readInteger("userId");
  print("_id -> $_id");
}

Future<void> createUser(String newUsername, String newName, String newEmail, String newPassword) async {
  final api = 'http://91.121.165.149/auth/local/register';
  
  Map data = {
    'username': newUsername,
    'name': newName,
    'email': newEmail,
    'password': newPassword
  };

  Response response = await post(
      api,
      headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
      },
      body: json.encode(data),
  );

  Map<String, dynamic> jsonResponse = json.decode(response.body);

  if (response.statusCode == 200) {
    //print("res -> $jsonResponse");
    //print('token: ${jsonResponse['jwt']}');
    //print('userId: ${jsonResponse['user']['id']}');
    int id = jsonResponse['user']['id'];
    print("id= $id");
    String name = jsonResponse['user']['name'];
    String username = jsonResponse['user']['username'];
    String email = jsonResponse['user']['email'];
    String token = jsonResponse['jwt'];

    userModel.setId(id);
    print("user id --> ${userModel.getId()}");
    userModel.setToken(token);
    userModel.setUsername(username);
    userModel.setName(name);
    userModel.setEmail(email);

    sharedPref.saveInteger("userId", id);
    sharedPref.save("name", name);
    sharedPref.save("email", email);
    sharedPref.save("token", token);

    //return jsonResponse;
  } else if(response.statusCode == 400) {
    String errorMsg = jsonResponse['message'][0]['messages'][0]['message'];
    throw Exception(errorMsg);
  } else {
    throw Exception('Failed to create user from API');
  }
}

/*void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}*/