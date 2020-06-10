import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/dashboard/menu.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:visiart/customFormUser/userInterests.dart';
import 'package:visiart/utils/FormUtils.dart';

import 'config/SharedPref.dart';
import 'config/config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final SharedPref _sharedPref = SharedPref();

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
      debugPrint("200");
      //print("res -> $jsonResponse");
      //print('token: ${jsonResponse['jwt']}');
      //print('userId: ${jsonResponse['user']['id']}');
      int id = jsonResponse['user']['id'];
      print("id= $id");
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
    } else {
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
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: AppLocalizations.of(context).translate("email"),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
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
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: AppLocalizations.of(context).translate("password"),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        onPressed: () {
          _onCLickLoginButton();
        },
        child: Text(AppLocalizations.of(context).translate('goBtn'),
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
              height: 250,
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
                        child: Text("Visiart",
                            style:
                                TextStyle(color: Colors.white, fontSize: 60)),
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      padding: EdgeInsets.only(top: 100),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(AppLocalizations.of(context).translate('home_slogan'),
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
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
                      text: AppLocalizations.of(context).translate('home_signUpLink'),
                      style: TextStyle(
                          color: Colors.blue, fontStyle: FontStyle.italic),
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
