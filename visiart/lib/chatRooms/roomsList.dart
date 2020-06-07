import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/Room.dart';
import 'package:visiart/chatRooms/roomChats.dart';
import 'package:visiart/chatRooms/roomCreate.dart';

void main() => runApp(new RoomsList());

class RoomsList extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Salons',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RoomsListPage(title: 'Liste des salons'),
    );
  }
}

class RoomsListPage extends StatefulWidget {
  RoomsListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RoomsListPageState createState() => new _RoomsListPageState();
}

class _RoomsListPageState extends State<RoomsListPage> {
  TextEditingController editingController = TextEditingController();

  List<Room> duplicateItems;

  var items = List<Room>();

  @override
  void initState() {
    _fetchRooms();
    super.initState();
  }

  Future<List<Room>> _fetchRooms() async {
    final roomAPIUrl = 'http://91.121.165.149/rooms';
    final response = await http.get(roomAPIUrl, headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNTkxMTE5MTcwLCJleHAiOjE1OTM3MTExNzB9.f1tCL0PmSCdsU9whCbf_26CRlMa1VTa3urwO7GOdyk8',
    });

    if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        this.duplicateItems = jsonResponse.map((room) => new Room.fromJson(room)).toList();
        setState(() {
          items.addAll(duplicateItems);
        });
      return jsonResponse.map((room) => new Room.fromJson(room)).toList();
    } else {
      throw Exception('Failed to load rooms from API');
    }
  }

  void filterSearchResults(String query) {
    List<Room> dummySearchList = List<Room>();
    dummySearchList.addAll(duplicateItems);
    if(query.isNotEmpty) {
      List<Room> dummyListData = List<Room>();
      dummySearchList.forEach((item) {
        if(item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }

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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Salons'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  /* return ListTile(
                    title: Text('${items[index].name}'),
                  ); */
                  return _row(items[index], Icons.work);
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
          
        ),
        
      ),
      
    );
  }
}