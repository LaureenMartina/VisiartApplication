import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Hobby.dart';
import 'package:visiart/models/Room.dart';
import 'package:visiart/chatRooms/roomChats.dart';
import 'package:visiart/chatRooms/roomCreate.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/models/UserRoomPrivate.dart';
import 'package:visiart/config/config.dart' as globals;

SharedPref sharedPref = SharedPref();

class RoomsListPage extends StatefulWidget{
  RoomsListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RoomsListPageState createState() => new _RoomsListPageState();
}

class _RoomsListPageState extends State<RoomsListPage>  with SingleTickerProviderStateMixin{
  TextEditingController editingController = TextEditingController();
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
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _getListHobbies() async{
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    
    final response = await http.get(
        globals.API_HOBBIES,
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

  void _fetchRooms() async {
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    this._userId = await sharedPref.readInteger(globals.API_USER_ID_KEY);
    
    final response = await http.get(globals.API_ROOMS_NO_PRIVATE_DISPLAY, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
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
          _publicRooms.clear();
          _publicRooms.addAll(duplicateItems);
        });
    } else {
      throw Exception('Failed to load rooms from API');
    }
  }

  void _fetchUserRoomsPrivate() async {
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    this._userId = await sharedPref.readInteger(globals.API_USER_ID_KEY);
    final roomAPIUrl = globals.API_USER_ROOM_PRIVATE_FETCH_ROOM_USER + _userId.toString();
    
    final response = await http.get(roomAPIUrl, headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization':
        'Bearer $token',
    });

    if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          _listUserRoomsPrivate = jsonResponse.map((userRoomPrivate) => new UserRoomPrivate.fromJson(userRoomPrivate)).toList();
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
        MaterialPageRoute(builder: (context) => RoomsChatsScreen(room: room)),
      ).then((value) {
        Timer(Duration(milliseconds: 100), () => { _fetchRooms()});
      }),
    child: Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 5, left: 15, right: 15),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: this._userId == room.userId ? Color.fromRGBO(252, 233, 216, 1.0) : Color.fromRGBO(173, 165, 177, 0.2),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: Icon(Icons.chat, color: Colors.black54,),
              title: Text(room.name, 
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 1.2
                ),
              ),
              trailing: room.lastDate != null && room.roomMessages.isNotEmpty && room.roomMessages.last != null &&  
              DateTime.parse(room.roomMessages.last.date).isAfter(DateTime.parse(room.lastDate))
              ? Badge(
                badgeContent: null,
                badgeColor: Colors.green[300],
                padding: EdgeInsets.all(10),
              ) : null,
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
        MaterialPageRoute(builder: (context) => RoomsChatsScreen(room: userRoomPrivate.room, userRoomPrivate: userRoomPrivate)),
      ).then((value) {
        Timer(Duration(milliseconds: 300), () => {_fetchUserRoomsPrivate()});
      }),
    child: Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 5, left: 15, right: 15),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: this._userId == userRoomPrivate.room.userId ? Color.fromRGBO(252, 233, 216, 1.0) : Color.fromRGBO(173, 165, 177, 0.2),
              borderRadius: BorderRadius.circular(23.0),
            ),
            child: ListTile(
              leading: Icon(Icons.chat, color: Colors.black54,),
              title: Text(userRoomPrivate.room.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 1.2
                ),
              ),
              trailing: userRoomPrivate.room.lastDate != null 
              && userRoomPrivate.room.roomMessages.isNotEmpty 
              && userRoomPrivate.room.roomMessages.last != null &&  
              DateTime.parse(userRoomPrivate.room.roomMessages.last.date).isAfter(DateTime.parse(userRoomPrivate.room.lastDate))
              ? Badge(
                badgeContent: null,
                badgeColor: Colors.green[300],
                padding: EdgeInsets.all(10),
              ) : null,
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    List<Tab> myTabs = <Tab>[
      Tab(text: AppLocalizations.of(context).translate('roomsList_roomsPublic')),
      Tab(text: AppLocalizations.of(context).translate('roomsList_roomsPrivate')),
    ];
    return new Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          backgroundColor: Color.fromRGBO(249, 248, 249, 0.7),
          elevation: 10,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.black87,
            labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 15.0),
            indicatorColor: Color.fromRGBO(82, 59, 92, 1.0),
            tabs: myTabs,
          ),
        ), 
        preferredSize: Size.fromHeight(60.0),
      ),
      body:TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          if (tab.text.contains(AppLocalizations.of(context).translate('roomsList_roomsPublic'))) {
            return Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
                    child: Container(
                      height: 50,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            this._query = value;
                          });
                          filterSearchResults();
                        },
                        controller: editingController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).translate("search"),
                          hintText: AppLocalizations.of(context).translate("search"),
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25.0))
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 10,left: 15, right: 15),
                    child: DropdownButton<String>(
                      hint: Text(
                        AppLocalizations.of(context).translate("roomsList_filterRooms"),
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
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
                        return _rowPrivate(_listUserRoomsPrivate[index], Icons.work);
                      },
                    ),
                  ),
                ]
              )
            );
          }
        }).toList(),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
        closeManually: true,
        animatedIcon: AnimatedIcons.add_event,
        elevation: 10,
        onPress: () {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => RoomsCreateScreen()),
          ).then((value) {
            Timer(Duration(milliseconds: 100), () {
              _fetchRooms();
              _fetchUserRoomsPrivate();
            });
          });
        },
      ),
    );
  }
}