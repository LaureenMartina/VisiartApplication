import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Hobby.dart';
import 'package:visiart/models/Room.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/models/User.dart';
import 'package:visiart/models/UserRoomPrivate.dart';
import 'package:visiart/config/config.dart' as globals;

BuildContext ctx;


SharedPref sharedPref = SharedPref();

class RoomAddUserPage extends StatefulWidget{

  RoomAddUserPage({Key key, this.room}) : super(key: key);
  final Room room;

  @override
  _RoomAddUserPageState createState() => new _RoomAddUserPageState(room);
}

class _RoomAddUserPageState extends State<RoomAddUserPage>  with SingleTickerProviderStateMixin{ TextEditingController editingController = TextEditingController();

  var _listUserRoomsPrivate = List<UserRoomPrivate>();
  var _listUserToAdd = List<User>();
  var _userId;
  var _userIdToAddId;
  String _usernameToSearch;
  Room room;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();


  _RoomAddUserPageState(Room room) {
    this.room = room;
  }

  List<Hobby> listHobbies = [new Hobby.fromJson({"id":0, "name":"None"})];
  var selectedHobby;

  @override
  void initState() {
    super.initState();
    sharedPref.readInteger(globals.API_USER_ID_KEY).then((value) => {
        setState(() {
            this._userId = value;
        })
      });
  }

  void _searchUsersByUsername() async {

    if (this._usernameToSearch != null && this._usernameToSearch.isNotEmpty) {
      var token = await sharedPref.read(globals.API_TOKEN_KEY);
      
      final roomAPIUrl = globals.API_USERS_USERNAME + this._usernameToSearch.toString()/*  + "&user_room_privates_null=true" */;
      
      final response = await http.get(roomAPIUrl, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        for (var i = 0; i < jsonResponse.length; i++) {
          if (jsonResponse[i]['id'] == _userId) {
            jsonResponse.remove(jsonResponse[i]);
          }

          List listPrivateRooms = jsonResponse[i]['user_room_privates'];
          for (var j = 0; j <  listPrivateRooms.length; j++) {
            if (jsonResponse[i]['user_room_privates'][j]['room'] == room.id) {
              jsonResponse.remove(jsonResponse[i]);
              break;
            }
          }
        }
        setState(() {
          this._listUserToAdd.clear();
          this._listUserToAdd.addAll(jsonResponse.map((user) => new User.fromJson(user)).toList());
        });
      } else {
        throw Exception('Failed to load user rooms from API');
      }
    } else {
      setState(() {
        this._listUserToAdd.clear();
      });
    }
  }

  void addUserToPrivateRoom(int userId) async {
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    
    var data = {
        'user': userId.toString(),
        'room' : this.room.id.toString(),
    };

    final response = await http.post(globals.API_USER_ROOM_PRIVATE,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data)
    );

    if (response.statusCode == 200) {
      //Toast ajout utilisateur 
    } else {
      throw Exception("Can't add user to private room");
    }
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: AppBar(
        title: new Text('Add User'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
        automaticallyImplyLeading: false,
      ),
      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(
            children: <Widget>[
              new TextFormField(
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  hintText: 'Username' ,
                ),
                onChanged: (String value) {
                  this._usernameToSearch = value;
                }
              ),
              new Container(
                width: screenSize.width,
                child: new RaisedButton(
                  child: new Text(
                    'Search',
                    style: new TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed: () => _searchUsersByUsername(),
                  color: Color.fromRGBO(82, 59, 92, 1.0),
                ),
                margin: new EdgeInsets.only(
                  top: 20.0
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 200.0,
                  child: new ListView.builder(
                    itemCount: this._listUserToAdd.length,
                    padding: const EdgeInsets.only(top: 10.0),
                    itemBuilder: (context, index) {
                      return new Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(_listUserToAdd[index].username),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              addUserToPrivateRoom(_listUserToAdd[index].id);
                              setState(() {
                                _listUserToAdd.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                      
                    }
                  )

                ),
              )
            ],
          ),
        ), 
    );
  }
}