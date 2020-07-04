import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/signUp/privacyPolicy.dart';
import 'package:visiart/utils/AlertUtils.dart';
import 'package:visiart/utils/FormUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:visiart/models/User.dart';
import 'package:http/http.dart' as http;

SharedPref sharedPref = SharedPref();
User userModel = new User();
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _valueCheckbox = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _pwdFocus = FocusNode();
  final _pwdConfFocus = FocusNode();

  SharedPref sharedPref = SharedPref();

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
      return;
    }
    if(_valueCheckbox == false) {
      showAlert(context, "Warning", "Private Policy must be checked", "Close");
      return;
    }
    _createUser(_nameController.text, _nameController.text, _emailController.text, _passwordController.text, 
      _valueCheckbox);
  }

  void _createUser(String newUsername, String newName, String newEmail, String newPassword, bool acceptPrivatePolicy) async {

    Map data = {
      'username': newUsername,
      'name': newName,
      'email': newEmail,
      'password': newPassword,
      'privatePolicy': acceptPrivatePolicy
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

      sharedPref.saveInteger("userId", id);
      sharedPref.save("name", name);
      sharedPref.save("email", email);
      sharedPref.save("token", token);

      Navigator.pushNamed(context, 'hobbies');
      //return jsonResponse;
    } else if (response.statusCode == 400) {
      String errorMsg = jsonResponse['message'][0]['messages'][0]['message'];
      //debugPrint("errormsg: " + errorMsg);
        showAlert(context, "Error", errorMsg, "Close");
      throw Exception(errorMsg);
    } else {
      throw Exception('Failed to create user from API');
    }
  }

  void _navigateToRGPD() { //Replacement
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => PrivacyPolicy()));
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
          icon: Icon(Icons.person, color: Color.fromRGBO(82, 59, 92, 0.8), size: 28,),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: AppLocalizations.of(context).translate("signup_username"),
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
          icon: Icon(Icons.email, color: Color.fromRGBO(82, 59, 92, 0.8), size: 28),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: AppLocalizations.of(context).translate("email"),
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
          icon: Icon(Icons.lock, color: Color.fromRGBO(82, 59, 92, 0.8), size: 28),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: AppLocalizations.of(context).translate('password'),
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
          icon: Icon(Icons.lock_outline, color: Color.fromRGBO(82, 59, 92, 0.8), size: 28,),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          hintText: AppLocalizations.of(context).translate('signup_pwdConfirmation'),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    
    final createAccountButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color.fromRGBO(82, 59, 92, 1.0),
      child: MaterialButton(
        onPressed: () {
          _onClickCreateAccountButton();
        },
        child: Text(AppLocalizations.of(context).translate('goBtn'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0)
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 220,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/imgs/signup.png'),
                      fit: BoxFit.fill),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: Container(
                        child: Center(
                          child: Text(AppLocalizations.of(context).translate("signup_createAccount"),
                            style: TextStyle(
                              color: Color.fromRGBO(82, 59, 92, 1.0), fontSize: 30, fontWeight: FontWeight.w600
                            ),
                          ),
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
                      nameField,
                      SizedBox(height: 20.0),
                      emailField,
                      SizedBox(height: 20.0),
                      passwordField,
                      SizedBox(height: 20.0),
                      passwordConfirmationField,
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Checkbox(
                            checkColor: Colors.white,
                            activeColor: Color.fromRGBO(173, 165, 177, 1.0),
                            value: _valueCheckbox,
                            onChanged: (bool value) {
                              setState(() {
                                  _valueCheckbox = value;
                              });
                            },
                          ),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                text: AppLocalizations.of(context).translate('rgpd_checkbox'),
                                style: TextStyle(
                                  color: Color.fromRGBO(82, 59, 92, 1.0), fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, fontSize: 14, letterSpacing: 1,
                                ),
                                children: <TextSpan>[
                                  TextSpan(text: AppLocalizations.of(context).translate('rgpd_title'),
                                    style: TextStyle(
                                        color: Colors.blueAccent, fontSize: 14),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _navigateToRGPD();
                                      }
                                  ),
                                  TextSpan(text: " (" + AppLocalizations.of(context).translate('rgpd_required') + ")",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _navigateToRGPD();
                                      }
                                  )
                                ]
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.0),
                      createAccountButon,
                    ],
                  ),
                ),
              ),
            ],
          ),
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
  var data = {
      "identifier" : name,
      "password" : password
  };
  if (currentUser != null) {
    final response = await http.post(
        'http://91.121.165.149/room-messages',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
        body: json.encode(data)
    );

    Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (response.statusCode == 200) {
        int id = jsonResponse['user']['id'];
        String name = jsonResponse['user']['name'];
        String username = jsonResponse['user']['username'];
        String email = jsonResponse['user']['email'];
        String token = jsonResponse['jwt'];

        userModel.setId(id);
        userModel.setToken(token);
        userModel.setUsername(username);
        userModel.setName(name);
        userModel.setEmail(email);

        sharedPref.saveInteger("userId", id);
        sharedPref.save("name", name);
        sharedPref.save("email", email);
        sharedPref.save("token", token);
    } else {
        throw Exception('Failed to post message from API');
    }
  } else {
    createUser(name, name, email, password);
  }

  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

 // ------ Get value from SharedPreferences ------
void displayIdFromSharedPrefs() async {
  var _id = await sharedPref.readInteger("userId");
  print("_id -> $_id");
}

Future<void> createUser(String newUsername, String newName, String newEmail, String newPassword) async {
  
  Map data = {
    'username': newUsername,
    'name': newName,
    'email': newEmail,
    'password': newPassword
  };

  Response response = await post(
      API_REGISTER,
      headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
      },
      body: json.encode(data),
  );

  Map<String, dynamic> jsonResponse = json.decode(response.body);

  if (response.statusCode == 200) {
    int id = jsonResponse['user']['id'];
    String name = jsonResponse['user']['name'];
    String username = jsonResponse['user']['username'];
    String email = jsonResponse['user']['email'];
    String token = jsonResponse['jwt'];

    userModel.setId(id);
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