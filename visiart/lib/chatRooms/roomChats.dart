import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/roomAddUser.dart';
import 'package:visiart/chatRooms/roomUpdate.dart';
import 'package:visiart/models/Room.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/models/Room_message.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart' as globals;
import 'package:visiart/models/UserRoomPrivate.dart';

SharedPref sharedPref = SharedPref();

class RoomsChatsScreen extends StatelessWidget {
  // This widget is the root of your application.
  final Room room;
  final UserRoomPrivate userRoomPrivate;
  RoomsChatsScreen({Key key, @required this.room, this.userRoomPrivate}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: room.name,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RoomsChatPage(room: room, userRoomPrivate: userRoomPrivate),
    );
  }
}

class RoomsChatPage extends StatefulWidget {
  RoomsChatPage({Key key, this.room, this.userRoomPrivate}) : super(key: key);
  final Room room;
  final UserRoomPrivate userRoomPrivate;

  @override
  _RoomsChatPageState createState() => new _RoomsChatPageState(room, userRoomPrivate);
}

class _RoomsChatPageState extends State<RoomsChatPage> {
    Room room;
    UserRoomPrivate userRoomPrivate;
    var _userid;
    var _userAdded;

    int _counterReagent;

    _RoomsChatPageState(Room room, UserRoomPrivate userRoomPrivate) {
      this.room = room;
      this.userRoomPrivate = userRoomPrivate;
    }

    ScrollController _controller = ScrollController(initialScrollOffset: 50.0);
    TextEditingController textEditingController = new TextEditingController();
    List<RoomMessage> messageList = [];

    var allMessage = [];
    
    @override
    void initState() {
      sharedPref.readInteger(globals.API_USER_ID_KEY).then((value) => {
        setState(() {
            this._userid = value;
        })
      });

      SharedPref().readInteger("counterReagent").then((value) => {
        setState(() {
          if(value == 99999) {
            _counterReagent = 0;
          } else {
            print("value: $value");
            _counterReagent = value;
          }
          print("_counterReagent: $_counterReagent");
        })
      });

      this._fetchRoomMessages();
      super.initState();
    }

    Future<List<RoomMessage>> _fetchRoomMessages() async {
      //final roomAPIUrl = 'http://91.121.165.149/room-messages'; //Rajouter id
      final roomAPIUrl = globals.API_BASE_URL+'/room-messages?room='+this.room.id.toString();
      var token = await sharedPref.read(globals.API_TOKEN_KEY);
      final response = await http.get(roomAPIUrl, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
          'Bearer $token',
      });

      if (response.statusCode == 200) {
          List jsonResponse = json.decode(response.body);
          var list = jsonResponse.map((roomMessages) => new RoomMessage.fromMainJson(roomMessages)).toList();
          if(list.isNotEmpty) {
            sharedPref.save("lastDateMessageVieweRoom_"+this.room.id.toString(), list.last.date);
          }
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
      var token = await sharedPref.read(globals.API_TOKEN_KEY);
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
      var token = await sharedPref.read(globals.API_TOKEN_KEY); 
      await http.put(
        globals.API_BASE_URL+'/rooms/'+roomId.toString(),
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, bool>{
            'enabled' : false
        }),
      );

    }
    void enableRoom(roomId) async {
      var token = await sharedPref.read(globals.API_TOKEN_KEY); 
      await http.put(
        globals.API_BASE_URL+'/rooms/'+roomId.toString(),
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, bool>{
            'enabled' : true
        }),
      );

    }

    void _unlinkThisRoom() async {
      final roomAPIUrl = globals.API_BASE_URL+'/user-room-privates/'+this.userRoomPrivate.id.toString();
      var token = await sharedPref.read(globals.API_TOKEN_KEY);
      final response = await http.put(roomAPIUrl, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':'Bearer $token',
      });

      if (response.statusCode == 200) {
          Navigator.push(context, 
            MaterialPageRoute(builder: (context) => RoomsListPage()),
          );
      } else {
        throw Exception('Failed to delete private room from API');
      }
    }

    void addNewMessage() async {

        if (textEditingController.text.trim().isNotEmpty) {

            this._userid = await sharedPref.readInteger(globals.API_USER_ID_KEY);

            var token = await sharedPref.read(globals.API_TOKEN_KEY);
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
              _counterReagent += 1;
              if(_counterReagent <= globals.COUNTER_REAGENT) {
                SharedPref().saveInteger("counterReagent", _counterReagent);
                print("increment reagent: $_counterReagent");
              }
              print(">= reagent: $_counterReagent");
              
              newMessage = RoomMessage.fromMainJson(json.decode(response.body));
              sharedPref.save("lastDateMessageVieweRoom_"+this.room.id.toString(), newMessage.date);
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

    AppBar _privateRoomOwner() {
      return AppBar(
              title: Text(this.room.name),
              actions: <Widget>[
                  // action button
                  IconButton(
                    tooltip: "Ajouter des utilisateur à cette room",
                      icon: Icon(Icons.add),
                      onPressed: () {
                          Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => RoomAddUser(room: this.room))
                          );
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
                  room.enabled != null && room.enabled ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        disableRoom(room.id);
                        Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => RoomsListPage()),
                        );
                        //Navigator.pop(context);
                      },
                  ) :
                  IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () {
                        enableRoom(room.id);
                        Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => RoomsListPage()),
                        );
                        //Navigator.pop(context);
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
    }

    AppBar _publicRoomOwner() {
      return AppBar(
              title: Text(this.room.name),
              actions: <Widget>[
                  // action button
                  IconButton(
                      icon: Icon(Icons.mode_edit),
                      onPressed: () {
                          Navigator.push(context, 
                              MaterialPageRoute(builder: (context) => RoomsUpdateScreen(room: this.room)),
                          );
                      },
                  ),
                  room.enabled != null && room.enabled ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        disableRoom(room.id);
                        Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => RoomsListPage()),
                        );
                        //Navigator.pop(context);
                      },
                  ) :
                  IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () {
                        enableRoom(room.id);
                        Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => RoomsListPage()),
                        );
                        //Navigator.pop(context);
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
    }
    AppBar _privateRoom() {
      return AppBar(
              title: Text(this.room.name),
              actions: <Widget>[
                  // action button
                  IconButton(
                      icon: Icon(Icons.remove),
                      tooltip: "Délier de cette room",
                      onPressed: () {
                          _unlinkThisRoom();
                      },
                  ),
              ],
          );
    }
    AppBar _publicRoom() {
      return AppBar(
          title: Text(this.room.name),
      );
    }

    AppBar buildAppBar(context) {
        if (this._userid == this.room.userId && this.room.private) { // Owner and private
          return this._privateRoomOwner();
        }
        else if (this._userid == this.room.userId && !this.room.private) { // Owner and public
          return this._publicRoomOwner();
        }
        else if (this._userid != this.room.userId && this.room.private) { // Private
          return this._privateRoom();
        } else { //public
          return this._publicRoom();
        }
    }        
                              
    Widget buildMessageTextField() {
      /* print("this.room.enabled");
      print(this.room.enabled); */
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
                        subtitle: 
                        data[index].username != null && data[index].date != null ? 
                        Text(data[index].username+data[index].date):Text(""),
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