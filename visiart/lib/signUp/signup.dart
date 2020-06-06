import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/customFormUser/userInterests.dart';
import 'package:visiart/home.dart';
import 'package:visiart/utils/AlertUtils.dart';
import 'package:visiart/utils/FormUtils.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _pwdFocus = FocusNode();
  final _pwdConfFocus = FocusNode();

  SharedPref sharedPref = SharedPref();
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();



  void _onClickCreateAccountButton() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordConfirmationController.text.isEmpty ||
        _passwordConfirmationController.text.isEmpty
        ) {
      showAlert(context, "Warning", "All fields must be complete", "Close");
      return;
    }
    if (_passwordController.text.toString() !=
        _passwordConfirmationController.text.toString()) {
      showAlert(context, "Warning", "Password doesn't match", "Close");
      return;
    }
    if (!EmailValidator.validate(_emailController.text)){
      showAlert(context, "Warning", "Email must be valid", "Close");
    }
    _createUser(_nameController.text, _nameController.text, _emailController.text,
        _passwordController.text);
  }


  Future<String> _signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

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

    _createUser(name, name, email, password);

    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  void _displayIdFromSharedPrefs() async {
    var _id = await sharedPref.readInteger("userId");
    print("_id -> $_id");
  }

  Future<void> _createUser(String newUsername, String newName, String newEmail,
      String newPassword) async {

    Map data = {
      'username': newUsername,
      'name': newName,
      'email': newEmail,
      'password': newPassword
    };

    Response response = await post(
      API_REGISTER,
      headers: API_HEADERS,
      body: json.encode(data),
    );

    Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      debugPrint("API_REGISTER ==> 200");
      debugPrint(response.toString());
      int id = jsonResponse['user']['id'];
      print("id= $id");
      String name = jsonResponse['user']['name'];
      String email = jsonResponse['user']['email'];
      String token = jsonResponse['jwt'];

      sharedPref.saveInteger("userId", id);
      sharedPref.save("name", name);
      sharedPref.save("email", email);
      sharedPref.save("token", token);

      Navigator.pushNamed(context, 'hobbies');

      //return jsonResponse;
    } else if (response.statusCode == 400) {
      String errorMsg = jsonResponse['message'][0]['messages'][0]['message'];
      debugPrint("errormsg: " + errorMsg);
        showAlert(context, "Error", errorMsg, "Close");
      throw Exception(errorMsg);
    } else {
      throw Exception('Failed to create user from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      focusNode: _nameFocus,
      onFieldSubmitted: (_) {
        fieldFocusChange(context, _nameFocus, _emailFocus);
      },
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
      decoration: InputDecoration(
          icon: Icon(Icons.person),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: "Nom / Pseudo",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final emailField = TextFormField(
      controller: _emailController,
      textInputAction: TextInputAction.next,
      focusNode: _emailFocus,
      onFieldSubmitted: (_) {
        fieldFocusChange(context, _emailFocus, _pwdFocus);
      },
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
      decoration: InputDecoration(
          icon: Icon(Icons.email),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: "Email",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final passwordField = TextFormField(
      controller: _passwordController,
      textInputAction: TextInputAction.next,
      focusNode: _pwdFocus,
      onFieldSubmitted: (_) {
        fieldFocusChange(context, _pwdFocus, _pwdConfFocus);
      },
      obscureText: true,
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
      decoration: InputDecoration(
          icon: Icon(Icons.lock),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: "Mot de passe",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final passwordConfirmationField = TextFormField(
      controller: _passwordConfirmationController,
      textInputAction: TextInputAction.done,
      focusNode: _pwdConfFocus,
      onFieldSubmitted: (_) {
        _onClickCreateAccountButton();
      },
      obscureText: true,
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
      decoration: InputDecoration(
          icon: Icon(Icons.lock),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: "Confirmation",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final createAccountButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        onPressed: () {
          _onClickCreateAccountButton();
        },
        child: Text("GO !",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0)
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/imgs/pattern.png'),
                    fit: BoxFit.fill),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: Container(
                      child: Center(
                        child: Text("Créer un Compte",
                            style:
                            TextStyle(color: Colors.white, fontSize: 30)),
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
                    SizedBox(height: 20.0),
                    passwordConfirmationField,
                    SizedBox(height: 15.0),
                    createAccountButon,
                  ],
                ),
              ),
            ),
            Padding(
              padding:
              EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
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
                    _signInWithGoogle().whenComplete(() {
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
                    _displayIdFromSharedPrefs();
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
