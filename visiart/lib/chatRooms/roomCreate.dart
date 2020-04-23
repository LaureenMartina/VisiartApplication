import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/Room.dart';
import 'package:http/http.dart' as http;

class RoomsCreateScreen extends StatefulWidget { 
  @override
  _RoomsCreateScreenState createState() => _RoomsCreateScreenState();
}


class _RoomsCreateData {
  String roomName = '';
  String roomThematic = '';
}
class _RoomsCreateScreenState extends State<RoomsCreateScreen> {

   
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _RoomsCreateData _data = new _RoomsCreateData();

  Future<http.Response> createRoom(String newRoomName, String newRoomThematic) {
    return http.post(
        'http://91.121.165.149/rooms',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer token',
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

        
        print('Printing the data.');
        print('roomName: ${_data.roomName}');
        print('roomThematic: ${_data.roomThematic}');

        this.createRoom(_data.roomName, _data.roomThematic);
    }
  }
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Ajout d\'un salon'),
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
                  hintText: 'Nom du salon',
                  //labelText: 'Nom du salon'
                ),
                onSaved: (String value) {
                  this._data.roomName = value;
                }
              ),
              new TextFormField(
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  hintText: 'Thème du salon',
                  //labelText: ''
                ),
                onSaved: (String value) {
                  this._data.roomThematic = value;
                }
              ),
              new Container(
                width: screenSize.width,
                child: new RaisedButton(
                  child: new Text(
                    'Créer un salon',
                    style: new TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed: () => this.submit(),
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
  
  
  /*Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppBar(
          iconTheme: IconThemeData(
            color: Colors.cyan, //change your color here
          ),
          title: Text("Ajout d'un salon"),
          centerTitle: true,
        ),
        RaisedButton(
          child: Text('Ajouter', style: TextStyle(fontSize: 20)),
          onPressed: () {
            //Do something
          },
          color: Colors.blue,
          textColor: Colors.white
        ),
      ],
    );
  }
  */
}
