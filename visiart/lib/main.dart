import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:visiart/account/account.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:visiart/awardsUser/awardsList.dart';
import 'package:visiart/chatRooms/roomChats.dart';
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/customFormUser/userInterests.dart';
import 'package:visiart/dashboard/menu.dart';
import 'package:visiart/drawingsUser/drawing.dart';
import 'package:visiart/drawingsUser/drawingARCore.dart';
import 'package:visiart/drawingsUser/myDrawings.dart';
import 'package:visiart/events/eventsList.dart';
import 'package:visiart/home.dart';
import 'package:visiart/machinelearning/recognition.dart';
import 'package:visiart/signUp/privacyPolicy.dart';
import 'package:visiart/signUp/signup.dart';

import 'localization/AppLocalization.dart';
import 'splashscreen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: _routes,
    );
  }
}

var _routes = <String, WidgetBuilder> {
  "/": (BuildContext context) => SplashScreen(),
  "connexion": (BuildContext context) => HomeScreen(),
  "hobbies": (BuildContext context) => UserInterestsScreen(),
  "rgpd": (BuildContext context) => PrivacyPolicy(),
  "inscription": (BuildContext context) => SignUpScreen(),
  "dashboard": (BuildContext context) => MenuBoardScreen(),
  "awards": (BuildContext context) => AwardsListScreen(),
  "account": (BuildContext context) => AccountScreen(),
  "drawing": (BuildContext context) => Draw(),
  "drawingAndroid": (BuildContext context) => DrawArCore(),
  "myDrawings": (BuildContext context) => MyDrawings(),
  "events": (BuildContext context) => EventsListScreen(),
  "rooms": (BuildContext context) => RoomsListPage(),
  "room_chats": (BuildContext context) => RoomsChatPage(),
  "painting_recognition": (BuildContext context) => PaintingRecognitionScreen()
};
