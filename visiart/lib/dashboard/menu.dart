import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/dashboard/dashboard.dart';
import 'package:visiart/events/eventsList.dart';
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

  final List<Widget> _children = [
    RoomsListPage(),
    DashboardScreen(),
    EventsListScreen()
  ];

  void _navigateToAccount() {
    Navigator.pushNamed(context, 'account');
  }

  ListTile _account() => ListTile(
    title: Text(AppLocalizations.of(context).translate('menu_myAccount'),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text(AppLocalizations.of(context).translate('menu_storedData'),
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.face, size: 40, color: Colors.teal[300]),
    onTap: () { _navigateToAccount(); },
  );

  ListTile _about() => ListTile(
    title: Text(AppLocalizations.of(context).translate('menu_about'),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text(AppLocalizations.of(context).translate('menu_aboutSubtitle'),
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.announcement, size: 40, color: Colors.indigoAccent[400]),
    onTap: () {  },
  );

  ListTile _paramsUser() => ListTile(
    title: Text(AppLocalizations.of(context).translate('menu_settings'),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text(AppLocalizations.of(context).translate('menu_settingsSubtitle'),
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.settings, size: 40, color: Colors.blueGrey[700]),
    onTap: () {  },
  );

  ListTile _logout() => ListTile(
    title: Text(AppLocalizations.of(context).translate('menu_logout'),
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text(AppLocalizations.of(context).translate('menu_logoutSubtitle'),
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.launch, size: 40, color: Colors.brown[900],),
    onTap: () {  },
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
        backgroundColor: Colors.deepPurple[800],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_username,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, letterSpacing: 2),
              ),
              accountEmail: Text(_mail,
                style: TextStyle(fontSize: 12, color: Colors.cyanAccent[100]),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo[900],
                child: Text(_pictureText),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/imgs/pattern.png"),
                  fit: BoxFit.fill
                )
              ),
            ),
            _account(),
            _about(),
            _paramsUser(),
            Divider(
              indent: 10,
              endIndent: 10,
              thickness: 1,
              color: Colors.deepPurpleAccent[200],
            ),
            _logout(),
          ],
        ),
      ),
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.forum, 
              color: Colors.lightBlue,
            ),
            title: Text('Salons'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.brown
            ),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_play,
              color: Colors.deepOrange,
            ),
            title: Text('Events'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
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