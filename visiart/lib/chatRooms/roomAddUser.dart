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


SharedPref sharedPref = SharedPref();
class RoomAddUser extends StatelessWidget {
  // This widget is the root of your application.

  final Room room;
  RoomAddUser({Key key, @required this.room}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Ajout d'un utilisateur au salon",
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RoomAddUserPage(),
    );
  }
}

class RoomAddUserPage extends StatefulWidget{

  RoomAddUserPage({Key key, this.room}) : super(key: key);
  final Room room;

  @override
  _RoomAddUserPageState createState() => new _RoomAddUserPageState(room);
}

class _RoomAddUserPageState extends State<RoomAddUserPage>  with SingleTickerProviderStateMixin{ TextEditingController editingController = TextEditingController();

  var _listUserRoomsPrivate = List<UserRoomPrivate>();
  var _userId;
  var _userIdToAddId;
  var _usernameToSearch;
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
    sharedPref.readInteger("userId").then((value) => {
        setState(() {
            this._userId = value;
        })
      });
  }
  @override
  Widget build(BuildContext context) {
    
    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: AppBar(
        title: new Text("Ajout d'un utilisateur"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Form(
          key: this._formKey,
          child: new ListView(
            children: <Widget>[
              new TextFormField(
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  hintText: 'name',
                  //labelText: 'Nom du salon'
                ),
                onSaved: (String value) {
                  this._usernameToSearch = value;
                }
              ),
              new Container(
                width: screenSize.width,
                child: new RaisedButton(
                  child: new Text(
                    "Valider",
                    style: new TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed: () => null,//this.submit(),
                  color: Colors.blue,
                ),
                margin: new EdgeInsets.only(
                  top: 20.0
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}