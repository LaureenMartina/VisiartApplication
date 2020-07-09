import 'dart:convert';
import 'dart:ui';
<<<<<<< HEAD
=======

import 'package:flutter/foundation.dart';
>>>>>>> 8ee59fc... WIP
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart' as globals;
<<<<<<< HEAD
import 'package:custom_switch/custom_switch.dart';
import 'package:visiart/models/Room.dart';

=======
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Hobby.dart';
>>>>>>> 8ee59fc... WIP

SharedPref sharedPref = SharedPref();

class RoomsCreateScreen extends StatefulWidget {
  RoomsCreateScreen({Key key, this.defaultRoomName = ""}) : super(key: key);
  final String defaultRoomName;

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

  bool nameReadOnly;
  String formHintName;

  List<Hobby> listHobbies = [];
  var selectedHobby;
  var selectedPrivateMessage = "";
  var selectedDisplayMessage = "";
  var selectedPrivateBool = false;
  var selectedDisplayBOOL = true;

  var isPrivate = false;
  var isDisplayed = false;

  int _counterInvested;

  @override
  void initState() {
    getListHobbies();
<<<<<<< HEAD
    
    SharedPref().readInteger("counterInvested").then((value) => {
        setState(() {
          if(value == 99999) {
            _counterInvested = 0;
          } else {
            _counterInvested = value;
          }
        })
    });

    super.initState();
=======
    nameReadOnly = widget.defaultRoomName != "";
    if (nameReadOnly) {
      formHintName = widget.defaultRoomName;
      isPrivate = false;
      isDisplayed = true;
    } else {
      formHintName = 'name';
    }
      super.initState();
>>>>>>> 8ee59fc... WIP
  }

  void createRoom(String newRoomName, String newRoomThematic) async {
    var token = await sharedPref.read('token');
    var userId = await sharedPref.readInteger(globals.API_USER_ID_KEY);
    var data = {
        'name': newRoomName,
        'display' : isDisplayed.toString(),
        'private' : isPrivate.toString(),
        "hobbies": [{
          "id": this._data.roomThematic
        }], 
        "user": userId, 
    };
    final response = await http.post(
<<<<<<< HEAD
        globals.API_ROOMS,
=======
        globals.API_ROOMS_CREATE,
>>>>>>> 8ee59fc... WIP
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: json.encode(data)
    );
    
    if (response.statusCode == 200) {
      _counterInvested += 1;
      if(_counterInvested <= globals.COUNTER_INVESTED) {
        SharedPref().saveInteger("counterInvested", _counterInvested);
      }
      if (isPrivate) {
        var jsonResponse = json.decode(response.body);
       // Room room = jsonResponse.map((room) => new Room.fromJson(room)).toList();
        _addUserToPrivateRoom(userId, jsonResponse['id']);
      }

      Navigator.push(
        context, MaterialPageRoute(builder: (context) => RoomsListPage()),
      );
    } else {
      throw Exception('Failed to post room from API');
    }
  }

  void _addUserToPrivateRoom(int userId, int roomId) async {
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    
    var data = {
        'user': userId.toString(),
        'room' : roomId.toString(),
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
  
  void getListHobbies() async{
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
          if (nameReadOnly) {
            this.listHobbies.addAll(items.where((element) => element.id == 7));
          } else {
            this.listHobbies.addAll(items);
          }
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

    selectedPrivateMessage = AppLocalizations.of(context).translate("no");
    selectedDisplayMessage = AppLocalizations.of(context).translate("yes");

    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
        title: new Text(AppLocalizations.of(context).translate("roomsCreate_addRomm")),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: this._formKey,
          child: ListView(
            children: <Widget>[
<<<<<<< HEAD
              SizedBox(height: 25,),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  hintText: AppLocalizations.of(context).translate("roomsCreate_roomName"),
=======
              new TextFormField(
                readOnly: nameReadOnly,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  hintText: formHintName,
                  //labelText: 'Nom du salon'
>>>>>>> 8ee59fc... WIP
                ),
                onSaved: (String value) {
                  if (nameReadOnly) {
                    value = widget.defaultRoomName;
                  }
                  this._data.roomName = value;
                }
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 30),
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(AppLocalizations.of(context).translate("roomsCreate_hobbyChoice")),
                  value: this.selectedHobby == null ? null : selectedHobby,
                  items: this.listHobbies.map((Hobby hobby) {
                    return DropdownMenuItem<String>(
                      value: hobby.id.toString(),
                      child: Text(hobby.name),
                    );
                  }).toList(),
                  onChanged: (_value) {
                    this._data.roomThematic = _value;
                     setState(() {
                      selectedHobby = _value;
                    });
                  },
                ),
              ),
<<<<<<< HEAD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate("roomsCreate_showRomm"), 
                    style: TextStyle(fontSize: 15),
                  ),
                  CustomSwitch(
                    activeColor: Color.fromRGBO(252, 233, 216, 1.0),
                    value: isDisplayed,
                    onChanged: (value) {
                      setState(() {
                        isDisplayed = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate("roomsCreate_privateRoom"),
                    style: TextStyle(fontSize: 15),
                  ),
                  CustomSwitch(
                    activeColor: Color.fromRGBO(252, 233, 216, 1.0),
                    value: isPrivate,
                    onChanged: (value) {
                      setState(() {
                        isPrivate = value;
                      });
                    },
                  ),
                ],
=======
              new Text(AppLocalizations.of(context).translate("roomsCreate_showRomm")),
              new Switch(
                
                value: isDisplayed,
                onChanged: (value){
                  if (nameReadOnly) return;
                  setState(() {
                    isDisplayed=value;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
                
              ),
              new Text(AppLocalizations.of(context).translate("roomsCreate_privateRomm")),
              new Switch(
                
                value: isPrivate,
                onChanged: (value){
                  if (nameReadOnly) return;
                  setState(() {
                    isPrivate=value;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
                
>>>>>>> 8ee59fc... WIP
              ),
              SizedBox(height: 20,),
              Container(
                height: 105,
                width: screenSize.width,
                padding: EdgeInsets.only(top: 60),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate("validate"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18
                    ),
                  ),
                  onPressed: () => this.submit(),
                  color: Color.fromRGBO(82, 59, 92, 1.0),
                ),
              ),
            ], 
          ),
        )
      ),
    );
  }
}
