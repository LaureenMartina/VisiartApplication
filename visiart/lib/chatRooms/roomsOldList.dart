import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/Room.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomCreate.dart';
import 'package:visiart/chatRooms/roomChats.dart';
import 'package:visiart/main.dart';

class RoomsListScreen extends StatefulWidget {
    @override
    _RoomsListScreenState createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
	TextEditingController editingController = TextEditingController();
  List<Room> roomList = [];
	List<Room> roomListFiltered = [];

	void filterSearchResults(String query) {
		List<Room> dummySearchList = List<Room>();
		dummySearchList.addAll(this.roomList);
		if(query.isNotEmpty) {
			List<Room> dummyListData = List<Room>();
			dummySearchList.forEach((item) {
				if(item.name.contains(query)) {
					dummyListData.add(item);
				}
			});
			setState(() {
			  roomListFiltered.addAll(dummyListData);
			});
			return;
		} else {
			setState(() {
				roomListFiltered.clear();
				roomListFiltered.addAll(roomList);
			});
		}
	}

    Future<List<Room>> _fetchRooms() async {
        final roomAPIUrl = 'http://91.121.165.149/rooms';
        final response = await http.get(roomAPIUrl, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNTg3ODk5MjY5LCJleHAiOjE1OTA0OTEyNjl9.vKilU-EeAiD3jlqyTV6H4WCNc9BMjjEmFDWyKH9wJh4',
        });

        if (response.statusCode == 200) {
          List jsonResponse = json.decode(response.body);
          setState(() {
            this.roomList = jsonResponse.map((room) => new Room.fromJson(room)).toList();
            this.roomListFiltered = roomList;
          });
          this.roomList = jsonResponse.map((room) => new Room.fromJson(room)).toList();
          this.roomListFiltered = roomList;
        	return this.roomListFiltered;
        } else {
          throw Exception('Failed to load rooms from API');
        }
    }

    ListView _roomsListView(data) {
        return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
            	return _row(data[index], Icons.work);
            });
    }
    GestureDetector _row(Room room, IconData icon) => GestureDetector(
      onTap: () =>
          //Scaffold.of(context).showSnackBar(SnackBar(content: Text(title))),
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RoomsChatsScreen(room: room)),  
			      //MaterialPageRoute(builder: (context) => RoomDetails()),
          ),
      child: new Card(
        //I am the clickable child
        child: new Column(
          children: <Widget>[
            //new Image.network(video[index]),
            new Padding(padding: new EdgeInsets.all(3.0)),
            new Text(
              room.name,
              style: new TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );

	TextField _searching() => TextField(
		controller: editingController,
		onChanged: (value) {
			filterSearchResults(value);
		},
		decoration: InputDecoration(
			labelText: "Search",
			hintText: "Search",
			prefixIcon: Icon(Icons.search),
			border: OutlineInputBorder(
				borderRadius: BorderRadius.all(Radius.circular(25.0))
			)
		),
	);

  @override
  Widget build(BuildContext context) {
    return Column(
		
      children: <Widget>[
		_searching(),
		DropdownButton(
			isExpanded: true,
			value: 'Music',
			icon: Icon(Icons.add_circle_outline),
			style: TextStyle(color: Colors.deepPurple),
			
			underline: Container(
				height: 2,
				color: Colors.deepPurpleAccent,
			),
			onChanged: (value) {
				//
			},
			items: <String>['Music', 'Book']
				.map<DropdownMenuItem<String>>((String value) {
				return DropdownMenuItem<String>(
				value: value,
				child: Text(value),
				);
			}).toList(),
		),
		SizedBox(
			height: 300,
			child: FutureBuilder<List<Room>>(
				future: _fetchRooms(),
				builder: (context, snapshot) {
				if (snapshot.hasData) {
					List<Room> data = snapshot.data;
					//print(data);
					return _roomsListView(data);
				} else if (snapshot.hasError) {
					return Text("${snapshot.error}");
				}
				return CircularProgressIndicator();
				},
			),
		),
		RaisedButton(
			child: Text('Ajouter un salon', style: TextStyle(fontSize: 20)),
			onPressed: () {
            	Navigator.push(
					context,
					MaterialPageRoute(builder: (context) => RoomsCreateScreen()),
            );
          },
          color: Colors.blue,
          textColor: Colors.white,
          elevation: 5,
        ),
      ],
    );
  }
}
