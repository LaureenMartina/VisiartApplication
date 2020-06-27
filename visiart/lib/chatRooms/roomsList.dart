import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:visiart/models/Hobby.dart';
import 'package:visiart/models/Room.dart';
import 'package:visiart/chatRooms/roomChats.dart';
import 'package:visiart/chatRooms/roomCreate.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Room_message.dart';
import 'package:visiart/models/UserRoomPrivate.dart';
import 'package:visiart/config/config.dart' as globals;

void main() => runApp(new RoomsList());

SharedPref sharedPref = SharedPref();

class RoomsList extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Liste des salons",
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RoomsListPage(title: "Liste des salons"),
    );
  }
}

class RoomsListPage extends StatefulWidget{
  RoomsListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RoomsListPageState createState() => new _RoomsListPageState();
}

class _RoomsListPageState extends State<RoomsListPage>  with SingleTickerProviderStateMixin{
  TextEditingController editingController = TextEditingController();
  List<Tab> myTabs = [
    Tab(text: "Salon"),
    Tab(text: "Salon")
  ];
  TabController _tabController;
  List<Room> duplicateItems;

  var _publicRooms = List<Room>();
  var _listUserRoomsPrivate = List<UserRoomPrivate>();
  var _userId;
  var _query = "";

  List<Hobby> listHobbies = [new Hobby.fromJson({"id":0, "name":"None"})];
  var selectedHobby;

  @override
  void initState() {
    super.initState();
    _getListHobbies();
    _fetchRooms();
    _fetchUserRoomsPrivate();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _getListHobbies() async{
    var token = await sharedPref.read("token");
    final response = await http.get(
        globals.API_BASE_URL+'/hobbies',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        }
    );
    if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        var items = jsonResponse.map((hobby) => new Hobby.fromJson(hobby)).toList();
        setState(() {
          this.listHobbies.addAll(items);
        });
    } else {
      throw Exception('Failed to load hobbies from API');
    }
  }

  int sortListRoomForUser(Room a, Room b) {
    bool isAUserMessage = false;
    bool isBUserMessage = false;
    for (var item in a.roomMessages) {
      if (item.userId == this._userId) {
        isAUserMessage = true;
      }
    }
    for (var item in b.roomMessages) {
      if (item.userId == this._userId) {
        isBUserMessage = true;
      }
    }
    if (isAUserMessage) {
      return -1;
    } else if (isBUserMessage) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<List<Room>> _fetchRooms() async {
    final roomAPIUrl = globals.API_BASE_URL+'/rooms?private=false';
    var token = await sharedPref.read("token");
    this._userId = await sharedPref.readInteger("userId");
    
    final response = await http.get(roomAPIUrl, headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization':
        'Bearer $token',
    });

    if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        this.duplicateItems = jsonResponse.map((room) => new Room.fromJson(room)).toList();
        this.duplicateItems.sort(sortListRoomForUser);
        this.duplicateItems.forEach((room) {
          sharedPref.read("lastDateMessageVieweRoom_"+room.id.toString()).then((value) =>
              room.lastDate = value
            );
         });
        setState(() {
          _publicRooms.addAll(duplicateItems);
        });
      return jsonResponse.map((room) => new Room.fromJson(room)).toList();
    } else {
      throw Exception('Failed to load rooms from API');
    }
  }

  void _fetchUserRoomsPrivate() async {
    var token = await sharedPref.read("token");
    this._userId = await sharedPref.readInteger("userId");
    final roomAPIUrl = globals.API_BASE_URL+'/user-room-privates?user.id='+_userId.toString();
    
    final response = await http.get(roomAPIUrl, headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization':
        'Bearer $token',
    });

    if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          this._listUserRoomsPrivate = jsonResponse.map((userRoomPrivate) => new UserRoomPrivate.fromJson(userRoomPrivate)).toList();
        });
    } else {
      throw Exception('Failed to load user rooms from API');
    }
  }

  void filterSearchResults() {
    List<Room> dummySearchList = List<Room>();
    if (selectedHobby != null && selectedHobby != '0') {
       duplicateItems.forEach((element) {
        if(element.hobbies.isNotEmpty && selectedHobby.toString() == element.hobbies.first.id.toString()){
          dummySearchList.add(element);
        }
      });
    } else {
      dummySearchList.addAll(duplicateItems);
    }
    if(this._query != null && this._query.isNotEmpty) {
      //Search bar none empty
      List<Room> dummyListData = List<Room>();
      dummySearchList.forEach((room) {
        if(room.name.toLowerCase().contains(this._query.toLowerCase())) {
          dummyListData.add(room);
        }
      });
      
      setState(() {
        _publicRooms.clear();
        _publicRooms.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _publicRooms.clear();
        _publicRooms.addAll(dummySearchList);
      });
    }
  }

  GestureDetector _rowPublic(Room room, IconData icon) => GestureDetector(
    onTap: () => 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RoomsChatsScreen(room: room), maintainState: true),
      ),
      //Navigator.pushNamed(context, "room_chats", arguments: RoomsChatsScreen(room: room)),
    child: Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: this._userId == room.userId ? Colors.deepPurple[300]:Colors.green[300],
              borderRadius: BorderRadius.circular(23.0),
              
            ),
            child: ListTile(
              leading: Icon(Icons.chat),
              title: Text(room.name),
              //trailing: room.roomMessages != null && room.roomMessages.isNotEmpty && room.roomMessages.last != null && room.roomMessages.last.userId != this._userId 
              trailing: room.lastDate != null && room.roomMessages.isNotEmpty && room.roomMessages.last != null &&  
              DateTime.parse(room.roomMessages.last.date).isAfter(DateTime.parse(room.lastDate))
              ? Badge(
                badgeContent: null,
                badgeColor: Colors.green[300],
                padding: EdgeInsets.all(10),
              ) : null,
              //subtitle: Text("Salon public"),
            ),
          ),
        ],
      ),
    ),
  );

  GestureDetector _rowPrivate(UserRoomPrivate userRoomPrivate, IconData icon) => GestureDetector(
    onTap: () => 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RoomsChatsScreen(room: userRoomPrivate.room, userRoomPrivate: userRoomPrivate), maintainState: true),
      ),
      //Navigator.pushNamed(context, "room_chats", arguments: RoomsChatsScreen(room: room)),
    child: Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: this._userId==userRoomPrivate.room.id? Colors.deepPurple[300]:Colors.green[300],
              borderRadius: BorderRadius.circular(23.0),
              
            ),
            child: ListTile(
              leading: Icon(Icons.chat),
              title: Text(userRoomPrivate.room.name),
              //trailing: room.roomMessages != null && room.roomMessages.isNotEmpty && room.roomMessages.last != null && room.roomMessages.last.userId != this._userId 
              trailing: userRoomPrivate.room.lastDate != null 
              && userRoomPrivate.room.roomMessages.isNotEmpty 
              && userRoomPrivate.room.roomMessages.last != null &&  
              DateTime.parse(userRoomPrivate.room.roomMessages.last.date).isAfter(DateTime.parse(userRoomPrivate.room.lastDate))
              ? Badge(
                badgeContent: null,
                badgeColor: Colors.green[300],
                padding: EdgeInsets.all(10),
              ) : null,
              //subtitle: Text("Salon public"),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    this.myTabs = <Tab>[
      Tab(text: "Salon public"),
      Tab(text: "Salon privée"),
    ];
    return new Scaffold(
      appBar: AppBar(
        title: new Text("Salons"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body:
        TabBarView(
          controller: _tabController,
          children: myTabs.map((Tab tab) {
            if (tab.text.contains("Salon public")) {
              return Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            this._query = value;
                          });
                          filterSearchResults();
                        },
                        controller: editingController,
                        decoration: InputDecoration(
                        labelText: "Search",
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: this.selectedHobby == null ? null : selectedHobby,
                        items: this.listHobbies.map((Hobby hobby) {
                          return new DropdownMenuItem<String>(
                            value: hobby.id.toString(),
                            child: new Text(hobby.name),
                          );
                        }).toList(),
                        isExpanded: true,
                        onChanged: (_value) {
                          setState(() {
                            selectedHobby = _value;
                          });
                          filterSearchResults();
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _publicRooms.length,
                        itemBuilder: (context, index) {
                          return _rowPublic(_publicRooms[index], Icons.work);
                        },
                      ),
                    ),
                    RaisedButton(
                      child: Text("Ajouter", style: TextStyle(fontSize: 20)),
                      onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RoomsCreateScreen()),
                        );
                      },
                      color: Colors.blue,
                      textColor: Colors.white,
                      elevation: 5,
                    ),
                  ]
                )
              );
            } else {
              return Container(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _listUserRoomsPrivate.length,
                        itemBuilder: (context, index) {
                          /* return FutureBuilder(
                            future: sharedPref.read("lastDateMessageVieweRoom_"+_listUserRoomsPrivate[index].room.id.toString()),
                            builder: (context, lastDate) {
                              return _rowPublic(_listUserRoomsPrivate[index].room, Icons.work, lastDate.data.toString());
                            },
                          ); */
                          return _rowPrivate(_listUserRoomsPrivate[index], Icons.work);
                        },
                      ),
                    ),
                    RaisedButton(
                      child: Text("Ajouter", style: TextStyle(fontSize: 20)),
                      onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RoomsCreateScreen()),
                        );
                      },
                      color: Colors.blue,
                      textColor: Colors.white,
                      elevation: 5,
                    ),
                  ]
                )
              );
            }
            
          }).toList(),
        ),
    );
  }
}