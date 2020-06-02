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

void main() => runApp(new RoomsChatsScreen());


class RoomsChatsScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Nom du salon',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RoomsChatPage(title: 'Nom du salon'),
    );
  }
}

class RoomsChatPage extends StatefulWidget {
  RoomsChatPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RoomsChatPageState createState() => new _RoomsChatPageState();
}

class _RoomsChatPageState extends State<RoomsChatPage> {
  // Declare a field that holds the Todo.
    //final Room room;

    // In the constructor, require a Todo.
    //RoomsChatsScreen(this.room) : super(this.room);

    ScrollController _controller = ScrollController(initialScrollOffset: 50.0);

    TextEditingController textEditingController = new TextEditingController();
    List<RoomMessage> messageList = [
        RoomMessage(
            id: 1,
            content: 'C\'est moi',
            userId: 26
        ),
        RoomMessage(
            id: 2,
            content: 'Ceci est un message',
            userId: 10
        ),
        RoomMessage(
            id: 3,
            content: 'est un tr super message',
            userId: 10
        ),
        
    ];

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

    void addNewMessage() {
        if (textEditingController.text.trim().isNotEmpty) {
            RoomMessage newMessage = RoomMessage(
                content: textEditingController.text.trim(),
            );

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
            title: Text("Nom de la room"),
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


  /* 
    @override
    Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return MaterialApp(
			home: Scaffold(
				appBar: AppBar(
                    title: Text(room.name),
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
                                deleteRoom(room.id);
                                Navigator.push(context, 
                                    MaterialPageRoute(builder: (context) => RoomsListPage()),
                                );
                            },
                        ),
                    ],
				),
			),
		);
  	} 
      */