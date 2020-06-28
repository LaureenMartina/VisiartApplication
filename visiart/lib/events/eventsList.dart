import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/events/eventDetails.dart';
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
      backgroundColor: Color.fromRGBO(252, 233, 216, 0.1),
      body: EventList(),
      floatingActionButton: SpeedDial(
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
        closeManually: true,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              backgroundColor: Colors.pink[800],
              child: Icon(Icons.favorite),
              label: 'favorite',
              onTap: () {
                print("favorie");
              }),
          SpeedDialChild(
              backgroundColor: Colors.teal[700],
              child: Icon(Icons.filter_list),
              label: 'Récent',
              onTap: () {
                print("récent");
              }),
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
  List<Event> events = List<Event>();
  List<Event> filteredEvents = List<Event>();
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    _fetchEvents();
    editingController.addListener(() {
      if (editingController.text.isNotEmpty) {
        filteredEvents = events
            .where((event) => event.title
                .toLowerCase()
                .contains(editingController.text.toLowerCase()))
            .toList();
        setState(() {});
      }
    });
    super.initState();
  }

  void _fetchEvents() async {
    var token = await sharedPref.read("token");
    var userLanguage = window.locale.languageCode;

    final response = await http.get(API_EVENT_LANG + userLanguage, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        events.addAll(
            jsonResponse.map((event) => new Event.fromJson(event)).toList());
        filteredEvents.addAll(events);
      });
    } else {
      throw Exception('Failed to load events from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
          child: TextField(
            onChanged: (value) {
              //search(value);
            },
            controller: editingController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              //labelText: "Search",
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)
                ),
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  onTap: () => {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EventDetails(specificEvent: filteredEvents[index])))
                  },
                  title: Text('${filteredEvents[index].title}',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      )),
                  subtitle: Text(
                    '${filteredEvents[index].description}',
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
                    child: Image.network('${filteredEvents[index].image}',
                        fit: BoxFit.cover),
                  ),
                  trailing: Icon(Icons.keyboard_arrow_right,
                      size: 50.0, color: Colors.blueGrey[500]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
