import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/Room.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomsList.dart';
import 'package:visiart/models/Room_message.dart';
import 'package:flutter/foundation.dart';
import 'package:visiart/config/SharedPref.dart';

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

    _RoomsChatPageState(Room room) {
      this.room = room;
    }

    ScrollController _controller = ScrollController(initialScrollOffset: 50.0);
    TextEditingController textEditingController = new TextEditingController();
    List<RoomMessage> messageList = [];

    @override
    void initState() {
        //_fetchRoomMessages();
       
         setState(() {
          this.messageList.addAll(this.room.roomMessages);
        });
        super.initState();
    }
  

    Future<List<RoomMessage>> _fetchRoomMessages() async {
      final roomAPIUrl = 'http://91.121.165.149/room-messages'; //Rajouter id
      final response = await http.get(roomAPIUrl, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNTkxMTE5MTcwLCJleHAiOjE1OTM3MTExNzB9.f1tCL0PmSCdsU9whCbf_26CRlMa1VTa3urwO7GOdyk8',
      });

      if (response.statusCode == 200) {
          List jsonResponse = json.decode(response.body);
          var list = jsonResponse.map((roomMessages) => new RoomMessage.fromJson(roomMessages)).toList();
          setState(() {
            this.messageList.addAll(list);
          });
        return list;
      } else {
        throw Exception('Failed to load rooms from API');
      }
  }

    //RoomsChatsScreen createState() => RoomsChatsScreen(room: room);
    void deleteRoom(roomId) {
        http.put(
            'http://91.121.165.149/rooms/'+roomId,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNTg3ODk5MjY5LCJleHAiOjE1OTA0OTEyNjl9.vKilU-EeAiD3jlqyTV6H4WCNc9BMjjEmFDWyKH9wJh4',
        },
        body: {
            'visible' : false
        }
            );
    }

    void disableRoom(roomId) {
            http.put(
                'http://91.121.165.149/rooms/'+roomId,
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNTg3ODk5MjY5LCJleHAiOjE1OTA0OTEyNjl9.vKilU-EeAiD3jlqyTV6H4WCNc9BMjjEmFDWyKH9wJh4',
                },
        body: {
            'visible' : false
        }
            );

    }

    void addNewMessage() async {

        if (textEditingController.text.trim().isNotEmpty) {

            var _userid = await sharedPref.readInteger("userId");
            var _token = await sharedPref.read("token");
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
                'http://91.121.165.149/room-messages',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'Authorization': 'Bearer $_token',
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

    AppBar buildAppBar(context) {
        return AppBar(
            title: Text(this.room.name),
            actions: <Widget>[
                // action button
                IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                        //
                    },
                ),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                        //deleteRoom(room.id);
                        Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => RoomsListPage()),
                        );
                    },
                ),
            ],
        );
    }


      
    Widget buildMessageTextField() {
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
                        hintText: 'Write your reply...',
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

    /* void initListMessage(room) {
      this.messageList.clear();
      setState(() {
        this.messageList.addAll(room.roomMessages);
      });
    } */
    
    @override
    Widget build(BuildContext context) {
        
        return new Scaffold(
            appBar: buildAppBar(context),
            body: Stack(
                children: <Widget>[
                    Column(
                        children: <Widget>[
                        // _appBar(),
                        Flexible(
                            child: _roomsListMeesageView(this.messageList),
                        ),
                        buildMessageTextField(),
                        ],
                    ),
                ],
            ),
        );
    }
}

ListView _roomsListMeesageView(data) {
   /*  print("data");
    print(data[0].id); */
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
            return ListTile(
                title: Text(data[index].content),
            );
    });
}