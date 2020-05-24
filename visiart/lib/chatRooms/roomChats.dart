import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/Room.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomsList.dart';

class RoomsChatsScreen extends StatelessWidget {
  // Declare a field that holds the Todo.
  final Room room;

  // In the constructor, require a Todo.
  RoomsChatsScreen({Key key, @required this.room}) : super(key: key);

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
}