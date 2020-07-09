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
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/UserEventFavorite.dart';

SharedPref sharedPref = SharedPref();

class EventsListScreen extends StatefulWidget {
  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {

  ScrollController _scrollController = ScrollController();

  var userLanguage = window.locale.languageCode;
  String name, username, avatar;
  bool isData = false;
  bool _favorite = false, _recent = false;
  int _count = 50;

  List<UserEventFavorite> _eventsFavorite = List<UserEventFavorite>();
  List<UserEventFavorite> filteredFavoriteEvents = List<UserEventFavorite>();

  List<Event> _events = List<Event>();
  List<Event> filteredEvents = List<Event>();
  Event castFavoriteEvent;

  List<Event> _eventsRecent = List<Event>();
  List<Event> filteredRecentEvents = List<Event>();

  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    _fetchEvents(_count);
    
    editingController.addListener(() {
      if (editingController.text.isNotEmpty) {
        filteredEvents = _events
            .where((event) => event.title
                .toLowerCase()
                .contains(editingController.text.toLowerCase()))
            .toList();
        setState(() {});
      }
    });

    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchEvents(_count + 50);
      }
    });

    super.initState();
  }

  void _fetchEvents(int _count) async {
    var token = await sharedPref.read("token");

    final response = await http.get(API_BASE_URL + "/events?_limit=" + _count.toString() + "&language=" + userLanguage, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        _events.addAll(
            jsonResponse.map((event) => new Event.fromJson(event)).toList());
        filteredEvents.addAll(_events);
      });
    } else {
      throw Exception('Failed to load events from API');
    }
  }

  void _fetchFavoriteEvents() async {
    var token = await sharedPref.read("token");
    var userId = await sharedPref.readInteger("userId");

    final response = await http.get(API_USER_EVENT_FAVORITES_USERID + userId.toString(), 
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        _eventsFavorite.addAll(
            jsonResponse.map((event) => new UserEventFavorite.fromJson(event)).toList());
        filteredFavoriteEvents.addAll(_eventsFavorite);
      });
    } else {
      throw Exception('Failed to load favorite userEventFavorite from API');
    }
  }

  void _fetchRecentEvents() async {
    var token = await sharedPref.read("token");

    final response = await http.get(API_EVENTS_RECENT + userLanguage, 
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        _eventsRecent.addAll(
            jsonResponse.map((event) => new Event.fromJson(event)).toList());
        filteredRecentEvents.addAll(_eventsRecent);
      });
    } else {
      throw Exception('Failed to load recent events from API');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(252, 233, 216, 0.1),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
            child: Container(
              height: 50,
              child: TextField(
                onChanged: (value) { /*search(value);*/ },
                controller: editingController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: AppLocalizations.of(context).translate("search"),
                  hintText: AppLocalizations.of(context).translate("search"),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: (_favorite) ? filteredFavoriteEvents.length : (_recent) ? filteredRecentEvents.length : filteredEvents.length,
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
                      if(_favorite) {
                        castFavoriteEvent = filteredFavoriteEvents[index].event,
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventDetails(specificEvent: castFavoriteEvent)))
                      }else if(_recent){
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventDetails(specificEvent: filteredRecentEvents[index])))
                      }else{
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventDetails(specificEvent: filteredEvents[index])))
                      }
                    },
                    title: Text( (_favorite) ? '${filteredFavoriteEvents[index].event.title}' : 
                      (_recent) ? '${filteredRecentEvents[index].title}' : '${filteredEvents[index].title}',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text( (_favorite) ? '${filteredFavoriteEvents[index].event.description}' : 
                      (_recent) ? '${filteredRecentEvents[index].description}' : '${filteredEvents[index].description}',
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
                      child: Image.network( (_favorite) ? '${filteredFavoriteEvents[index].event.image}' : 
                        (_recent) ? '${filteredRecentEvents[index].image}' : '${filteredEvents[index].image}',
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
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
        closeManually: false,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          //favorite filter
          SpeedDialChild(
            backgroundColor: Colors.pink[800],
            child: Icon(Icons.favorite),
            label: AppLocalizations.of(context).translate("event_filterFavorite"),
            onTap: () {
              _favorite = true;
              _recent = false;
              _eventsRecent = [];
              filteredRecentEvents = [];
              filteredEvents = [];
              _fetchFavoriteEvents();
            }),
          // Recent filter
          SpeedDialChild(
            backgroundColor: Colors.teal[700],
            child: Icon(Icons.filter_list),
            label: AppLocalizations.of(context).translate("event_filterRecent"),
            onTap: () {
              _recent = true;
              _favorite = false;
              _eventsFavorite = [];
              _events = [];
              filteredFavoriteEvents = [];
              filteredEvents = [];
              _fetchRecentEvents();
            }),
          // ALL no filter
          SpeedDialChild(
            backgroundColor: Color.fromRGBO(173, 165, 177, 1.0),
            child: Icon(Icons.all_inclusive),
            label: AppLocalizations.of(context).translate("event_filterNone"),
            onTap: () {
              _favorite = false;
              _recent = false;
              _eventsFavorite = [];
              _eventsRecent = [];
              filteredRecentEvents = [];
              filteredFavoriteEvents = [];
              _fetchEvents(_count);
            }),
        ],
      ),
    );
  }
}