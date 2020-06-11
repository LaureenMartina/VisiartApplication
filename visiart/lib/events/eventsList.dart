import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/models/Event.dart';

SharedPref sharedPref = SharedPref();

class EventsListScreen extends StatefulWidget {
  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {

  String name, username, avatar;
  bool isData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: EventList(),
      floatingActionButton: SpeedDial(
        closeManually: true,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            backgroundColor: Colors.redAccent[200],
            child: Icon(Icons.favorite),
            label: 'favorite',
            onTap: () {
              print("favorie");
            }
          ),
          SpeedDialChild(
            backgroundColor: Colors.greenAccent[200],
            child: Icon(Icons.filter_list),
            label: 'Récent',
            onTap: () {
              print("récent");
            }
          ),
          SpeedDialChild(
            backgroundColor: Colors.blueAccent[200],
            child: Icon(Icons.map),
            label: 'Map',
            onTap: () {
              print("récent");
            }
          ),
        ],
      ),
    );
  }
}


class EventList extends StatefulWidget {
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {

  var events = List<Event>();
  List<Event> futureEvent;

  @override
  void initState() {
    _fetchEvents();
    super.initState();
  }

  Future<List<Event>> _fetchEvents() async {
      var token = await sharedPref.read("token");
      
      final response = await http.get(
        API_EVENT, 
        headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer $token',
        }
      );

      if (response.statusCode == 200) {
          List jsonResponse = json.decode(response.body);
          this.futureEvent = jsonResponse.map( (event) => new Event.fromJson(event) ).toList();
          setState(() {
            events.addAll(futureEvent);
          });
        return jsonResponse.map( (event) => new Event.fromJson(event) ).toList();
      } else {
        throw Exception('Failed to load events from API');
      }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Card(
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            onTap: () => {},
            title: Text('${events[index].title}',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )
            ),
            subtitle: Text('${events[index].description}',
              style: TextStyle(
                fontSize: 16.0,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            leading: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 100,
                minHeight: 100,
                maxWidth: 100,
                maxHeight: 100,
              ),
              child: Image.network('${events[index].image}', fit: BoxFit.cover),
            ),
            trailing: Icon(Icons.keyboard_arrow_right, size: 50.0, color: Colors.blueGrey[500]),
          ),
        );
      },
    );

    // return CustomScrollView(
    //   slivers: <Widget>[
    //     SliverList(
    //       delegate: SliverChildBuilderDelegate((context, index) {
    //         return Container(
    //           alignment: Alignment.center,
    //           height: 180,
    //           color: Colors.red[100 * (index % 10)],
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             //crossAxisAlignment: CrossAxisAlignment.start,
    //             children: <Widget>[          
    //               Expanded(
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: <Widget>[
    //                     Row(
    //                       children: <Widget>[
    //                         Expanded(
    //                           child: Container(
    //                             margin: const EdgeInsets.only(top: 12, bottom: 10, left: 12),
    //                             child: Text("TITLE EVENT $index",
    //                               style: TextStyle(
    //                                 fontSize: 18.0,
    //                                 color: Colors.black,
    //                                 fontWeight: FontWeight.bold,
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     Container(
    //                       margin: EdgeInsets.only(right: 10, left: 12),
    //                       child: Text("Description event : aaaaaaaaaaaaaaaaa",
    //                         style: TextStyle(
    //                           fontSize: 16.0,
    //                         ),
    //                         maxLines: 3,
    //                         overflow: TextOverflow.ellipsis,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         );
    //       }, childCount: 10,
    //       ),
    //     ),
    //   ],
    // );
  }
}
