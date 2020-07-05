import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/models/Room.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/config/config.dart' as globals;

SharedPref sharedPref = SharedPref();
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

  Future<http.Response> updateRoom(String newRoomName) async{
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    return http.put(
        globals.API_BASE_URL+'/rooms/'+this.room.id.toString(),
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
            'name': newRoomName,
        }),
    );
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
    final Size screenSize = MediaQuery.of(context).size;
    
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          this.room.name
        ),
      ),
      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Form(
          key: this._formKey,
          child: new ListView(
            children: <Widget>[
              new TextFormField(
                keyboardType: TextInputType.text,
                onSaved: (String value) {
                  this.newRoomName = value;
                }
              ),
              new Container(
                width: screenSize.width,
                child: new RaisedButton(
                  child: new Text(
                    "Valid",
                    style: new TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed: () => {
                    this.submit(),
                    Navigator.pop(context)
                    
                  },
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
