import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/events/eventsList.dart';
import 'package:visiart/dashboard/dashboard.dart';
import 'package:visiart/chatRooms/roomsList.dart';

class MenuBoardScreen extends StatefulWidget {
  @override
  _MenuBoardScreenState createState() => _MenuBoardScreenState();
}

class _MenuBoardScreenState extends State<MenuBoardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _children = [
    DashboardScreen(),
    RoomsListScreen(),
    EventsListScreen()
  ];

  final account = ListTile(
    title: Text('Mon Compte',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text('Vos données enregistrées',
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.face, size: 40, color: Colors.teal[300]),
    onTap: () {  },
  );

  final about = ListTile(
    title: Text('A Propos',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text('Notre équipe, notre application',
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.announcement, size: 40, color: Colors.indigoAccent[400]),
    onTap: () {  },
  );

  final paramsUser = ListTile(
    title: Text('Paramètres',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text('Données de l\'application',
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.settings, size: 40, color: Colors.blueGrey[700]),
    onTap: () {  },
  );

  final logout = ListTile(
    title: Text('Déconnexion',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    subtitle: Text('Bye Bye',
      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic
      ),
    ),
    leading: Icon(Icons.launch, size: 40, color: Colors.brown[900],),
    onTap: () {  },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visiart'),
        elevation: 5.0,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Exemple Machin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, letterSpacing: 2),
              ),
              accountEmail: Text('exemple.machin@gmail.com',
                style: TextStyle(fontSize: 12, color: Colors.cyanAccent[100]),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo[900],
                child: Text("EM"),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/imgs/pattern.png"),
                  fit: BoxFit.fill
                )
              ),
            ),
            account,
            about,
            paramsUser,
            Divider(
              indent: 10,
              endIndent: 10,
              thickness: 1,
              color: Colors.deepPurpleAccent[200],
            ),
            logout,
          ],
        ),
      ),
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            title: Text('Salons'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_play),
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