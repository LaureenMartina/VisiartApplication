import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/models/Hobby.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/config/config.dart' as globals;


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
    
    SharedPref().readInteger("counterInvested").then((value) => {
        setState(() {
          if(value == 99999) {
            _counterInvested = 0;
          } else {
            print("value: $value");
            _counterInvested = value;
          }
          print("_counterInvested: $_counterInvested");
        })
    });

    super.initState();
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
        'http://91.121.165.149/rooms',
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
        print("increment invested: $_counterInvested");
      }
      print(">= invested : $_counterInvested");

      Navigator.push(
        context, MaterialPageRoute(builder: (context) => RoomsListPage()),
      );
    } else {
      throw Exception('Failed to post room from API');
    }
  }
  
  void getListHobbies() async{
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
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

    selectedPrivateMessage = AppLocalizations.of(context).translate("no");
    selectedDisplayMessage = AppLocalizations.of(context).translate("yes");

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).translate("roomsCreate_addRomm")),
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
                  this._data.roomName = value;
                }
              ),
              new DropdownButton<String>(
                hint: Text(AppLocalizations.of(context).translate("roomsCreate_hobbyChoice")),
                value: this.selectedHobby == null ? null : selectedHobby,
                items: this.listHobbies.map((Hobby hobby) {
                  return new DropdownMenuItem<String>(
                    value: hobby.id.toString(),
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
              new Text(AppLocalizations.of(context).translate("roomsCreate_showRomm")),
              new Switch(
                
                value: isDisplayed,
                onChanged: (value){
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
                  setState(() {
                    isPrivate=value;
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
                
              ),
              new Container(
                width: screenSize.width,
                child: new RaisedButton(
                  child: new Text(
                    AppLocalizations.of(context).translate("validate"),
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
              ),
            ],

            
          ),
          
        )
      ),
    );
  }
}
