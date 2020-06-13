import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/models/Room.dart';
import 'package:http/http.dart' as http;

class RoomsUpdateScreen extends StatefulWidget { 
  @override
  _RoomsUpdateScreenState createState() => _RoomsUpdateScreenState();
}


class _RoomsUpdateData {
  String roomName = '';
  String roomThematic = '';
  Room roomToUpdate;
}
class _RoomsUpdateScreenState extends State<RoomsUpdateScreen> {

   
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _RoomsUpdateData _data = new _RoomsUpdateData();

  Future<http.Response> updateRoom(String newRoomName, String newRoomThematic) {
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

  Room getRoom(){
    return _RoomsUpdateData().roomToUpdate;
  }

  void submit() {
    // First validate form.
    if (this._formKey.currentState.validate()) {
        _formKey.currentState.save(); // Save our form now.

        
        //print('Printing the data.');
        //print('roomName: ${_data.roomName}');
        //print('roomThematic: ${_data.roomThematic}');

        this.updateRoom(_data.roomName, _data.roomThematic);
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
                controller: TextEditingController(text: _RoomsUpdateData().roomToUpdate.name),
                decoration: new InputDecoration(
                  hintText: _RoomsUpdateData().roomToUpdate.name,
                  
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
                    'Modifier le salon',
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
