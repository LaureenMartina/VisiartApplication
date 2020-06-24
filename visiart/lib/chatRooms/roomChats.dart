import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/roomUpdate.dart';
import 'package:visiart/models/Room.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Room_message.dart';
import 'package:flutter/foundation.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/models/User.dart';
import 'package:visiart/config/config.dart' as globals;

SharedPref sharedPref = SharedPref();

//void main() => runApp(new RoomsChatsScreen());


class RoomsChatsScreen extends StatelessWidget {
  // This widget is the root of your application.
  final Room room;
  RoomsChatsScreen({Key key, @required this.room}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: room.name,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RoomsChatPage(room: room),
    );
  }
}

class RoomsChatPage extends StatefulWidget {
  RoomsChatPage({Key key, this.room}) : super(key: key);
  final Room room;

  @override
  _RoomsChatPageState createState() => new _RoomsChatPageState(room);
}

class _RoomsChatPageState extends State<RoomsChatPage> {
    Room room;
    var _userid;
    var _userAdded;

    _RoomsChatPageState(Room room) {
      this.room = room;
    }

    ScrollController _controller = ScrollController(initialScrollOffset: 50.0);
    TextEditingController textEditingController = new TextEditingController();
    List<RoomMessage> messageList = [];

    var allMessage = [];
    

    @override
    void initState() {
      sharedPref.readInteger("userId").then((value) => {
        setState(() {
            this._userid = value;
        })
      });
      this._fetchRoomMessages();
      super.initState();
    }

    Future<List<RoomMessage>> _fetchRoomMessages() async {
      //final roomAPIUrl = 'http://91.121.165.149/room-messages'; //Rajouter id
      final roomAPIUrl = globals.API_BASE_URL+'/room-messages?room='+this.room.id.toString();
      var token = await sharedPref.read("token");
      final response = await http.get(roomAPIUrl, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
          'Bearer $token',
      });

      if (response.statusCode == 200) {
          List jsonResponse = json.decode(response.body);
          var list = jsonResponse.map((roomMessages) => new RoomMessage.fromMainJson(roomMessages)).toList();
          this.setState(() {
            this.messageList.addAll(list);
          });
        return list;
      } else {
        throw Exception('Failed to load rooms from API');
      }
  }

    //RoomsChatsScreen createState() => RoomsChatsScreen(room: room);
    void deleteRoom(roomId) async {
      var token = await sharedPref.read("token");
      http.put(
            globals.API_BASE_URL+'/rooms/'+roomId,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, bool>{
            'display' : false
        }),
      );
    }

    void disableRoom(roomId) async {
      var token = await sharedPref.read("token"); 
      http.put(
        globals.API_BASE_URL+'/rooms/'+roomId.toString(),
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, bool>{
            'enable' : false
        }),
      );

    }

    void _addUserToPrivateRoom() async {
      //Need route get userid by username
      /* http.post(
        'http://91.121.165.149/room-messages',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
        },
        body: json.encode(data)
      ); */
    }

    void addNewMessage() async {

        if (textEditingController.text.trim().isNotEmpty) {

            this._userid = await sharedPref.readInteger("userId");

            var token = await sharedPref.read("token");
            RoomMessage newMessage = RoomMessage(
                content: textEditingController.text.trim(),
                userId: _userid
            ); 
            var data = {
                "content": textEditingController.text.trim(),
                "user": {
                    "id": _userid
                },
                "room": {
                    "id": this.room.id
                }, 
            };
            final response = await http.post(
                globals.API_BASE_URL+'/room-messages',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': 'Bearer $token',
                },
                body: json.encode(data)
            );

            if (response.statusCode == 200) {
                //
            } else {
                throw Exception('Failed to post message from API');
            }

            setState(() {
                messageList.add(newMessage);
                textEditingController.text = '';
            });
            /* Timer(Duration(milliseconds: 500),
                    () => _controller.jumpTo(_controller.position.maxScrollExtent)); */
        }
    }
    void showAddMembersModal(int roomId, BuildContext context) async {
        showDialog(
            context: context,
            child: new AlertDialog(
                title: Text('Ajout d\'un amie'),
                content: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                  hintText: 'name',
                  //labelText: 'Nom du salon'
                  ),
                  onChanged: (value) => this._userAdded,
                ),
              actions: [
                new FlatButton(
                  child: Text('Valider'),
                  onPressed: () => {
                      //Faire la requête serverside
                      _addUserToPrivateRoom(),
                      Navigator.of(context, rootNavigator: true).pop(context)
                      //Navigator.pop(context)
                    },
                ),
              ],
            ),
        );
    }

    AppBar buildAppBar(context) {
        if(this._userid == this.room.userId) {
          return AppBar(
              title: Text(this.room.name),
              actions: <Widget>[
                  // action button
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                          this.room.private ? showAddMembersModal(room.id, context): null;
                      },
                  ),
                  IconButton(
                      icon: Icon(Icons.mode_edit),
                      onPressed: () {
                          Navigator.push(context, 
                              MaterialPageRoute(builder: (context) => RoomsUpdateScreen(room: this.room)),
                          );
                      },
                  ),
                  IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        disableRoom(room.id);
                        /* Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => RoomsListPage()),
                        ); */
                        Navigator.pop(context);
                      },
                  ),
                  IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                          deleteRoom(room.id);
                          Navigator.push(context, 
                              MaterialPageRoute(builder: (context) => RoomsListPage()),
                          );
                      },
                  ),
              ],
          );
        } else {
          return AppBar(
              title: Text(this.room.name),
          );
        }
        
    }
                        
                        
                              
    Widget buildMessageTextField() {
      if (this.room.enabled != null && !this.room.enabled) {
        return Container();
      }
        return Container(    
            child: Container(
            height: 50.0,      
            child: Row(
                children: <Widget>[
                Expanded(
                    child: TextField(            
                    controller: textEditingController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'text',
                        hintStyle: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xffAEA4A3),
                        ),
                    ),
                    textInputAction: TextInputAction.send,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                    ),
                    onSubmitted: (_) {
                        addNewMessage();
                    },
                    onTap: () {
                        /*  Timer(
                        Duration(milliseconds: 300),
                        () => _controller.jumpTo(_controller.position.maxScrollExtent)); */
                    },
                    ),
                    
                ),
                Container(
                    width: 50.0,
                    child: InkWell(
                    onTap: addNewMessage,
                    child: Icon(
                        Icons.send,
                        color: Color(0xFFdd482a),
                    ),
                    ),
                )
                ],
            ),
            ),
        );
    }
    
    @override
    Widget build(BuildContext context) {
      
        return new Scaffold(
            appBar: buildAppBar(context),
            body: Stack(
                children: <Widget>[
                    Column(
                        children: <Widget>[
                        Flexible(
                            child: _roomsListMeesageView(this.messageList, this._userid, this.allMessage),
                        ),
                        buildMessageTextField(),
                        ],
                    ),
                ],
            ),
        );
    }
                        
}

ListView _roomsListMeesageView(data, userId, allMessage) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
            //var username = allMessage.indexWhere(data[index]);
            /* var username;
            
            Iterable<RoomMessage> result = allMessage.where( (roomMessage) {
              return roomMessage.id == data[index].id;
            });
            
            debugPrint("username : " +  result.toString()); */
            //var username = "test";
            if (data[index].userId == userId) {
                return Container(
                    //color:  Theme.of(context).accentColor, 
                    
                    width: 10,
                    padding: EdgeInsets.all(12.0),
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        color: Colors.deepPurple[300],
                        borderRadius: BorderRadius.circular(23.0),
                    ),
                    child: ListTile(
                        title: Text(data[index].content),
                        subtitle: Text(data[index].username+data[index].date.toString()),
                    ),
                );
            } else {
                return Container(
                    padding: EdgeInsets.all(12.0),
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        color: Colors.green[500],
                        borderRadius: BorderRadius.circular(23.0),
                    ),
                    child: ListTile(
                        title: Text(data[index].content),
                        subtitle: Text(data[index].username),
                    ),
                );
            }
    });
}