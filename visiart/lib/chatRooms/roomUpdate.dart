import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomChats.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart' as globals;
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Room.dart';

SharedPref sharedPref = SharedPref();
BuildContext ctx;

class RoomsUpdateScreen extends StatefulWidget {
  RoomsUpdateScreen({Key key, this.room}) : super(key: key);
  final Room room;

  @override
  _RoomsUpdateScreenState createState() => _RoomsUpdateScreenState(room);
}

/* class _RoomsUpdateData {
  String roomName = '';
  Room roomToUpdate;
} */
class _RoomsUpdateScreenState extends State<RoomsUpdateScreen> {
  Room room;
  String newRoomName;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  //_RoomsUpdateData _data = new _RoomsUpdateData();
  _RoomsUpdateScreenState(Room room) {
    this.room = room;
  }

  void updateRoom(String newRoomName) async {
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    var response = await http.put(
      globals.API_ROOMS + '/' + this.room.id.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'name': newRoomName,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, newRoomName);


    } else {
      throw Exception('Failed to load rooms from API');
    }
  }

  void submit() {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.
      this.updateRoom(this.newRoomName);
    }
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(this.room.name),
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: _formKey,
            child: new ListView(
              children: <Widget>[
                new TextFormField(
                    validator: (value) {
                      debugPrint("COUCOU: validator ${ctx}");
                      if (value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    onSaved: (String value) {
                      this.newRoomName = value;
                    }),
                new Container(
                  width: screenSize.width,
                  child: new RaisedButton(
                    child: new Text(
                      "Valid",
                      style: new TextStyle(color: Colors.white),
                    ),
                    onPressed: () => {
                      this.submit(),
                    },
                    color: Color.fromRGBO(82, 59, 92, 1.0),
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                )
              ],
            ),
          )),
    );
  }
}
