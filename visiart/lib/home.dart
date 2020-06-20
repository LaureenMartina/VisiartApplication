import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:visiart/dashboard/menu.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:visiart/customFormUser/userInterests.dart';
import 'package:visiart/utils/AlertUtils.dart';
import 'package:visiart/utils/FormUtils.dart';
import 'config/SharedPref.dart';
import 'config/config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomeScreen> {

  ImageProvider bgHome;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final SharedPref _sharedPref = SharedPref();

  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    _checkIfAlreadyLogged();
    super.initState();
    bgHome = AssetImage("assets/imgs/home.png");
  }

  @override
  void didChangeDependencies() async {
    await precacheImage(bgHome, context);
    super.didChangeDependencies();
  }

  void _checkIfAlreadyLogged() {
    _sharedPref.read("token").then((token) => {
      if (token != null) {
        _navigateToDashboard()
      }
    });
  }

  void _navigateToSignUpScreen() {
    Navigator.pushNamed(context, 'inscription');
  }

  void _navigateToUserInterestsScreen() {
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => UserInterestsScreen()));
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      new MaterialPageRoute(builder: (context) => MenuBoardScreen()));
  }

  void _onCLickLoginButton() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showAlert(context, "Warning", "All fields must be filled", "Close");
      return;
    }
    _login(_emailController.text, _passwordController.text);
  }

  Future<void> _login(String username, String password) async {
    Map data = {'identifier': username, 'password': password};

    Response response = await post(
      API_LOGIN,
      headers: API_HEADERS,
      body: json.encode(data),
    );

    Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      int id = jsonResponse['user']['id'];
      String username = jsonResponse['user']['username'];
      String email = jsonResponse['user']['email'];
      String token = jsonResponse['jwt'];

      _sharedPref.saveInteger("userId", id);
      _sharedPref.save("name", username);
      _sharedPref.save("email", email);
      _sharedPref.save("token", token);
      List<dynamic> hobbies = jsonResponse['user']['hobbies'];
      if (hobbies.isEmpty) {
        _navigateToUserInterestsScreen();
      } else {
        _navigateToDashboard();
      }
    } else if (response.statusCode == 400){
      String errorMsg = jsonResponse['message'][0]['messages'][0]['message'];
      //debugPrint("errormsg: " + errorMsg);
      showAlert(context, "Error", errorMsg, "Close");
      throw Exception(errorMsg);
    } else {
      //throw Exception('Failed to Log In');
    }
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

    if (email == null) {
      _createUser(name, name, email, password);
    } else {
      _login(email, password);
    }


    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }
  
 void _createUser(String newUsername, String newName, String newEmail, String newPassword) async {

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
      int id = jsonResponse['user']['id'];
      String name = jsonResponse['user']['name'];
      String email = jsonResponse['user']['email'];
      String token = jsonResponse['jwt'];

      _sharedPref.saveInteger("userId", id);
      _sharedPref.save("name", name);
      _sharedPref.save("email", email);
      _sharedPref.save("token", token);

      Navigator.pushNamed(context, 'hobbies');

    } else if (response.statusCode == 400) {
      String errorMsg = jsonResponse['message'][0]['messages'][0]['message'];
      showAlert(context, "Error", errorMsg, "Close");
      throw Exception(errorMsg);
    } else {
      throw Exception('Failed to create user from API');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    
    final emailField = TextFormField(
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      focusNode: _emailFocus,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        fieldFocusChange(context, _emailFocus, _passwordFocus);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white70,
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: AppLocalizations.of(context).translate("email"),
        hintStyle: TextStyle(color: Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final passwordField = TextFormField(
      obscureText: true,
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      controller: _passwordController,
      focusNode: _passwordFocus,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) {
        _onCLickLoginButton();
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white70,
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: AppLocalizations.of(context).translate("password"),
        hintStyle: TextStyle(color: Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );

    final loginButon = SizedBox(
      width: double.infinity,
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.orange[300],
        child: MaterialButton(
          onPressed: () {
            _onCLickLoginButton();
          },
          child: Text(AppLocalizations.of(context).translate('goBtn'),
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0)
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ));

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          // background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/imgs/home.png"),
                fit: BoxFit.cover
              ),
            ),
          ),
          // Header
          Column(
            children: <Widget>[
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Container(
                      child: Text(
                        "Visiart",
                        style:
                          TextStyle(
                            //fontFamily: 'Montserrat',
                            color: Colors.black, 
                            fontSize: 60,
                            letterSpacing: 2.5,
                            decoration: TextDecoration.overline,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationColor: Colors.black12,
                            decorationThickness: 2,
                            shadows: [
                              Shadow(
                                color: Colors.red[200],
                                blurRadius: 5,
                                offset: Offset(3.5, 0.0),
                              ),
                              Shadow(
                                color: Colors.orange[200],
                                blurRadius: 5,
                                offset: Offset(3.5, 0.0),
                              ),
                            ],
                          ),
                      ),
                    ),
                  ),
                ],
              ),
              // Slogan
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Container(
                      child: Align(
                        alignment: Alignment.center,
                          child: Text(AppLocalizations.of(context).translate('home_slogan'),
                            style:
                              TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.red[200],
                                    blurRadius: 5,
                                    offset: Offset(1, 0.0),
                                  ),
                                  Shadow(
                                    color: Colors.orange[200],
                                    blurRadius: 5,
                                    offset: Offset(1, 0.0),
                                  ),
                                ],
                              ),
                          ),
                      ),
                    ),
                  ),
                ],
              ),
              // Fields Connexion
              Padding(
                padding: EdgeInsets.only(top: 70.0, left: 20.0, right: 20.0),
                child: Container(
                  //child: Padding(
                    //padding: EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        emailField,
                        SizedBox(height: 20.0),
                        passwordField,
                        SizedBox(height: 30.0),
                        loginButon,
                      ],
                    ),
                  //),
                ),
              ),
              // OU Gmail
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text("Continuer avec :", 
                  style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold , fontStyle: FontStyle.italic, fontSize: 16, letterSpacing: 2,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
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
                      child: Container(
                        width: 200,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(30),
                          image: DecorationImage(
                            image: AssetImage("assets/icons/google.png"),
                          )
                        ),
                      ),
                    ),
                  ],
                )
              ),
              // Text new inscription
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: RichText(
                  text: TextSpan(
                    text: AppLocalizations.of(context).translate('home_signUpLink'),
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 16, letterSpacing: 1,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _navigateToSignUpScreen();
                      },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
