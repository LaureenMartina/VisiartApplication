import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/dashboard/dashboard.dart';
import 'package:visiart/events/eventsList.dart';
import 'package:visiart/home.dart';
import 'package:visiart/localization/AppLocalization.dart';

class MenuBoardScreen extends StatefulWidget {
  @override
  _MenuBoardScreenState createState() => _MenuBoardScreenState();
}

class _MenuBoardScreenState extends State<MenuBoardScreen> {
  int _selectedIndex = 1;
  String _username = "";
  String _mail = "";
  String _pictureText = "";
  SharedPref _sharedPref = SharedPref();

  final List<Widget> _children = [
    RoomsListPage(),
    DashboardScreen(),
    EventsListScreen()
  ];

  void _navigateToAccount() {
    Navigator.pushNamed(context, 'account');
  }

  void _navigateToPaintingRecognition(){
    Navigator.pushNamed(context, "painting_recognition");
  }

  void _navigateToMyDrawings() {
    Navigator.pushNamed(context, 'myDrawings');
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  ListTile _account() => ListTile(
    title: Text(AppLocalizations.of(context).translate('menu_myAccount'),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text(AppLocalizations.of(context).translate('menu_storedData'),
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.fingerprint, size: 40, color: Colors.teal[700]),
    onTap: () { _navigateToAccount(); },
  );

  ListTile _recognition() => ListTile(
    title: Text(AppLocalizations.of(context).translate("ml_paintingReco"),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text(AppLocalizations.of(context).translate('ml_paintingRecoDetail'),
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.brush, size: 40, color: Colors.teal[300]),
    onTap: () { _navigateToPaintingRecognition(); },
  );

  ListTile _drawingUser() => ListTile(
    title: Text(AppLocalizations.of(context).translate('menu_myDrawings'),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(82, 59, 92, 1.0)),
    ),
    subtitle: Text(AppLocalizations.of(context).translate('menu_myDrawingsSubtitle'),
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.perm_media, size: 40, color: Colors.pink[800]),
    onTap: () { _navigateToMyDrawings(); },
  );

  ListTile _logout() => ListTile(
    title: Text(AppLocalizations.of(context).translate('menu_logout'),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text(AppLocalizations.of(context).translate('menu_logoutSubtitle'),
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.directions_run, size: 40, color: Colors.brown[900],),
    onTap: () {  
      _sharedPref.remove("token");
      _navigateToLogin();
    },
  );

  void _setupInfo() async {
    _username = await SharedPref().read("name");
    _mail = await SharedPref().read("email");
    if (_username.length >= 2){
      _pictureText = _username.substring(0, 2);
    } else {
      _pictureText = _username.substring(0, 1);
    }
    setState(() {});
  }
  
  @override
  void initState() {
    _setupInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visiart'),
        centerTitle: true,
        elevation: 5.0,
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_username,
                style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18,
                  color: Color.fromRGBO(252, 233, 216, 1.0), letterSpacing: 2),
              ),
              accountEmail: Text(_mail,
                style: TextStyle(fontSize: 14, color: Color.fromRGBO(252, 233, 216, 1.0), fontWeight: FontWeight.w500),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Color.fromRGBO(82, 59, 92, 0.8),
                child: Text(_pictureText.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.colorBurn),
                  image: AssetImage("assets/imgs/menu.png"),
                  fit: BoxFit.fitWidth
                )
              ),
            ),
            _account(),
            _drawingUser(),
            _recognition(),
            SizedBox(height: 15,),
            Divider(
              indent: 10,
              endIndent: 10,
              thickness: 1,
              color: Color.fromRGBO(82, 59, 92, 1.0),
            ),
            _logout(),
          ],
        ),
      ),
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.forum,
            ),
            title: Text(AppLocalizations.of(context).translate("menu_bottomNavBar_Room")),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            title: Text(AppLocalizations.of(context).translate("menu_bottomNavBar_Home")),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_play,
            ),
            title: Text(AppLocalizations.of(context).translate("menu_bottomNavBar_Event")),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(82, 59, 92, 1.0),
        backgroundColor: Color.fromRGBO(249, 248, 249, 1.0),
        selectedIconTheme: IconThemeData(
          color: Color.fromRGBO(82, 59, 92, 1.0),
          opacity: 1.0,
          size: 25.0
        ),
        unselectedIconTheme: IconThemeData(
          color: Color.fromRGBO(87, 74, 77, 0.5),
          opacity: 1.0,
          size: 25.0
        ),
        elevation: 20,
        selectedFontSize: 16,
        unselectedItemColor: Colors.grey,
        onTap: (value) {
          _selectedIndex = value;
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }
}