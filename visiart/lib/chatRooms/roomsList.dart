import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:visiart/chatRooms/Room.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/chatRooms/roomCreate.dart';

class RoomsListScreen extends StatefulWidget {
  @override
  _RoomsListScreenState createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {

    Future<List<Room>> _fetchRooms() async {
        final roomAPIUrl = 'http://91.121.165.149/rooms';
        final response = await http.get(roomAPIUrl, headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer token',
        });

        if (response.statusCode == 200) {
            List jsonResponse = json.decode(response.body);
            return jsonResponse.map((room) => new Room.fromJson(room)).toList();
        } else {
            throw Exception('Failed to load rooms from API');
        }
    }

    ListView _roomsListView(data) {
        return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
            return _tile(data[index].name, Icons.work);
            }
        );
    }

   ListTile _tile(String title, IconData icon) => ListTile(
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
            )),
        leading: Icon(
          icon,
          color: Colors.blue[500],
        ),
    );
    @override
    Widget build(BuildContext context) {
        return Column(
        children: <Widget>[
            SizedBox(
                height: 300,
                child: FutureBuilder<List<Room>>(
                    future: _fetchRooms(),
                    builder: (context, snapshot) {
                        if (snapshot.hasData) {
                            List<Room> data = snapshot.data;
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
