import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/Room.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/models/Hobby.dart';


SharedPref sharedPref = SharedPref();
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

  List<Hobby> listHobbies = [];
  var selectedHobby;
  var selectedPrivateMessage = "NON";
  var selectedDisplayMessage = "OUI";
  var selectedPrivateBool = false;
  var selectedDisplayBOOL = true;
  @override
    void initState() {
      getListHobbies();
      
      super.initState();
    }

  Future<http.Response> createRoom(String newRoomName, String newRoomThematic) async {
    var token = await sharedPref.read('token');
    final response = await http.post(
        'http://91.121.165.149/rooms',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
            'name': newRoomName,
            'hobbies' : selectedHobby,
            'display' : selectedDisplayBOOL.toString(),
            'private' : selectedPrivateBool.toString(),

        }),
    );
    if (response.statusCode == 200) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RoomsListPage()),
        );
    } else {
      throw Exception('Failed to post room from API');
    }
  }
  Future<http.Response> getListHobbies() async{
    var token = await sharedPref.read("token");
    final response = await http.get(
        'http://91.121.165.149/hobbies',
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

  void submit() {
    // First validate form.
    if (this._formKey.currentState.validate()) {
        _formKey.currentState.save(); // Save our form now.
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
              new DropdownButton<String>(
                hint: Text("choisir le hobby"),
                value: this.selectedHobby == null ? null : selectedHobby,
                items: this.listHobbies.map((Hobby hobby) {
                  return new DropdownMenuItem<String>(
                    value: hobby.name,
                    child: new Text(hobby.name),
                  );
                }).toList(),
                onChanged: (_value) {
                  this._data.roomThematic = _value;
                   setState(() {
                    selectedHobby = _value;
                  });
                },
              ),
              new DropdownButton<String>(
                hint: Text("Affiché ?"),
                value: this.selectedDisplayMessage == null ? null : selectedDisplayMessage,
                items: <String>['OUI', 'NON']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_value) {
                  if(_value == "OUI") {
                    setState(() {
                      selectedDisplayBOOL = true;
                      selectedDisplayMessage = "OUI";
                    });
                  } else {
                    setState(() {
                      selectedDisplayBOOL = false;
                      selectedDisplayMessage = "NON";
                    });
                  }
                  
                },
              ),
              new DropdownButton<String>(
                hint: Text("Privé ?"),
                value: this.selectedPrivateMessage == null ? null : selectedPrivateMessage,
                items: <String>['OUI', 'NON']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_value) {
                  if(_value == "OUI") {
                    setState(() {
                      selectedPrivateBool = true;
                      selectedPrivateMessage = "OUI";
                    });
                  } else {
                    setState(() {
                      selectedPrivateBool = false;
                      selectedPrivateMessage = "NON";
                    });
                  }
                  
                },
              ),
              /* new TextFormField(
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  hintText: 'Thème du salon',
                  //labelText: ''
                ),
                onSaved: (String value) {
                  this._data.roomThematic = value;
                }
              ), */
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
