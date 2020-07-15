import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomAddUser.dart';
import 'package:visiart/chatRooms/roomUpdate.dart';
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart' as globals;
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Room.dart';
import 'package:visiart/models/Room_message.dart';
import 'package:visiart/models/UserRoomPrivate.dart';

SharedPref sharedPref = SharedPref();

BuildContext ctx;

class RoomsChatsScreen extends StatelessWidget {
  // This widget is the root of your application.
  final Room room;
  final UserRoomPrivate userRoomPrivate;

  RoomsChatsScreen({Key key, @required this.room, this.userRoomPrivate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return new MaterialApp(
      title: room.name,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: new RoomsChatPage(room: room, userRoomPrivate: userRoomPrivate),
    );
  }
}

class RoomsChatPage extends StatefulWidget {
  RoomsChatPage({Key key, this.room, this.userRoomPrivate}) : super(key: key);
  final Room room;
  final UserRoomPrivate userRoomPrivate;

  @override
  _RoomsChatPageState createState() =>
      new _RoomsChatPageState(room, userRoomPrivate);
}

class _RoomsChatPageState extends State<RoomsChatPage> {
  Room room;
  UserRoomPrivate userRoomPrivate;
  var _userid;
  var _userAdded;

  int _counterReagent = 0;

  _RoomsChatPageState(Room room, UserRoomPrivate userRoomPrivate) {
    this.room = room;
    this.userRoomPrivate = userRoomPrivate;
  }

  ScrollController _scrollController =
      ScrollController(initialScrollOffset: 50.0);
  TextEditingController textEditingController = new TextEditingController();
  List<RoomMessage> messageList = [];

  var allMessage = [];

  @override
  void initState() {
    super.initState();
    sharedPref.readInteger(globals.API_USER_ID_KEY).then((value) => {
          setState(() {
            this._userid = value;
          })
        });

    SharedPref().readInteger("counterReagent").then((value) => {
          setState(() {
            if (value == 99999) {
              _counterReagent = 0;
            } else {
              _counterReagent = value;
            }
          })
        });

    this._fetchRoomMessages();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mounted) {
        _listviewScrollToBottom();
        timer.cancel();
      }
    });
  }

  void _listviewScrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<List<RoomMessage>> _fetchRoomMessages() async {
    final roomAPIUrl =
        globals.API_ROOMS_MESSAGE_ID_ROOM + this.room.id.toString();

    var token = await sharedPref.read(globals.API_TOKEN_KEY);

    final response = await http.get(roomAPIUrl, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      var list = jsonResponse
          .map((roomMessages) => new RoomMessage.fromMainJson(roomMessages))
          .toList();
      if (list.isNotEmpty) {
        sharedPref.save("lastDateMessageVieweRoom_" + this.room.id.toString(),
            list.last.date);
      }
      this.setState(() {
        this.messageList.addAll(list);
      });

      return list;
    } else {
      throw Exception('Failed to load rooms from API');
    }
  }

  void deleteRoom(roomId) async {
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    await http.put(
      globals.API_ROOMS + '/' + roomId.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, bool>{'display': false}),
    );
  }

  void disableRoom(roomId) async {
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    await http.put(
      globals.API_ROOMS + '/' + roomId.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, bool>{'enabled': false}),
    );
  }

  void enableRoom(roomId) async {
    var token = await sharedPref.read(globals.API_TOKEN_KEY);
    await http.put(
      globals.API_ROOMS + '/' + roomId.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, bool>{'enabled': true}),
    );
  }

  void _unlinkThisRoom() async {
    final roomAPIUrl = globals.API_USER_ROOM_PRIVATE +
        '/' +
        this.userRoomPrivate.id.toString();
    var token = await sharedPref.read(globals.API_TOKEN_KEY);

    final response = await http.delete(roomAPIUrl, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      Navigator.push(
        ctx,
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
          content: textEditingController.text.trim(), userId: _userid);

      var data = {
        "content": textEditingController.text.trim(),
        "user": {"id": _userid},
        "room": {"id": this.room.id},
      };

      final response = await http.post(globals.API_ROOMS_MESSAGE,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(data));

      if (response.statusCode == 200) {
        _counterReagent += 1;
        if (_counterReagent <= globals.COUNTER_REAGENT) {
          SharedPref().saveInteger("counterReagent", _counterReagent);
        }

        newMessage = RoomMessage.fromMainJson(json.decode(response.body));
        sharedPref.save("lastDateMessageVieweRoom_" + this.room.id.toString(),
            newMessage.date);
      } else {
        throw Exception('Failed to post message from API');
      }

      setState(() {
        messageList.add(newMessage);
        textEditingController.text = '';
      });
      /*Timer(Duration(milliseconds: 500),
            () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent)); */
    }
  }

  AppBar _privateRoomOwner(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
      elevation: 10,
      automaticallyImplyLeading: false,
      title: Text(this.room.name),
      actions: <Widget>[
        IconButton(
          tooltip: AppLocalizations.of(ctx).translate('roomsChats_unlinkRoom'),
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RoomAddUserPage(room: this.room)));
          },
        ),
        IconButton(
          icon: Icon(Icons.mode_edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RoomsUpdateScreen(room: this.room)),
            ).then((value) {
              if (value == null) return;
              setState(() {
                room.name = value;
              });
            });
          },
        ),
        room.enabled != null && room.enabled
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  disableRoom(room.id);
                  Navigator.pop(ctx);
                },
              )
            : IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  enableRoom(room.id);
                  Navigator.pop(ctx);
                },
              ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            deleteRoom(room.id);
            Navigator.pop(ctx);
          },
        ),
      ],
    );
  }

  AppBar _publicRoomOwner(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
      elevation: 10,
      automaticallyImplyLeading: false,
      title: Text(this.room.name),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.mode_edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RoomsUpdateScreen(room: this.room)),
            ).then((value) {
              if (value == null) return;
              setState(() {
                room.name = value;
              });
            });
          },
        ),
        room.enabled != null && room.enabled
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  disableRoom(room.id);
                  Navigator.pop(ctx);
                },
              )
            : IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  enableRoom(room.id);
                  Navigator.pop(ctx);
                },
              ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            deleteRoom(room.id);
            Navigator.pop(ctx);
          },
        ),
      ],
    );
  }

  AppBar _privateRoom(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
      elevation: 10,
      automaticallyImplyLeading: false,
      title: Text(this.room.name),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.remove),
          tooltip: AppLocalizations.of(ctx).translate('roomsChats_unlinkRoom'),
          onPressed: () {
            _unlinkThisRoom();
          },
        ),
      ],
    );
  }

  AppBar _publicRoom(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
      elevation: 10,
      automaticallyImplyLeading: false,
      title: Text(this.room.name),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    if (this._userid == this.room.userId && this.room.private) {
      // Owner and private
      return this._privateRoomOwner(context);
    } else if (this._userid == this.room.userId && !this.room.private) {
      // Owner and public
      return this._publicRoomOwner(context);
    } else if (this._userid != this.room.userId && this.room.private) {
      // Private
      return this._privateRoom(context);
    } else {
      //public
      return this._publicRoom(context);
    }
  }

  Widget buildMessageTextField() {
    if (this.room.enabled != null && !this.room.enabled) {
      return Container();
    }
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(ctx).translate('roomsChats_textHint'),
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
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  width: 50.0,
                  child: InkWell(
                    onTap: addNewMessage,
                    child: Icon(
                      Icons.send,
                      color: Color(0xFFdd482a),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: Column(
              children: <Widget>[
                Flexible(
                  child: _roomsListMeesageView(this.messageList, this._userid, this.allMessage, this._scrollController),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: buildMessageTextField(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

ListView _roomsListMeesageView(data, userId, allMessage, controller) {
  return ListView.builder(
      controller: controller,
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        if (data[index].userId == userId) {
          return Container(
            width: 10,
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(252, 233, 216, 1.0),
              borderRadius: BorderRadius.circular(23.0),
            ),
            child: ListTile(
              title: Text(data[index].content),
              subtitle: data[index].username != null && data[index].date != null
                  ? Text(data[index].username + " " + data[index].date)
                  : Text(""),
            ),
          );
        } else {
          return Container(
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(173, 165, 177, 0.2),
              borderRadius: BorderRadius.circular(23.0),
            ),
            child: ListTile(
              title: Text(data[index].content),
              subtitle: data[index].username != null && data[index].date != null
                  ? Text(data[index].username + " " + data[index].date)
                  : Text(""),
            ),
          );
        }
      });
}
