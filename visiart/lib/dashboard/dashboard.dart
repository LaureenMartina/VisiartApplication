import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/models/Event.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/events/eventDetails.dart';

SharedPref sharedPref = SharedPref();

class DashboardScreen extends StatefulWidget {

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _username = "";
  
  var events = List<Event>();
  List<Event> futureEvent;

  @override
  void initState() {
    _getUsername();
    _fetchEvents();
    super.initState();
  }

  void _getUsername() async {
    _username = await SharedPref().read("name");
    setState(() {});
  }

  Card _awardsCard() => Card(
    elevation: 50,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30)
    ),
    color: Colors.pink[800],
    child: Padding(
      padding: EdgeInsets.only(top:55, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate("dashboard_titleAwards"), 
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4),
        ],
      ),
    ),
  );

  Card _drawingCard() => Card(
    elevation: 50,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30)
    ),
    color: Colors.teal[700],
    child: Padding(
      padding: EdgeInsets.only(top: 60, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(AppLocalizations.of(context).translate("dashboard_titleDrawing"),
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4),
        ],
      ),
    ),
  );

  Future<List<Event>> _fetchEvents() async {
    var token = await sharedPref.read("token");
    var userLanguage = window.locale.languageCode;
    var year = DateFormat.y().format(DateTime.now());
    var month = DateFormat.M().format(DateTime.now());

    if(month.length < 2) month = "0" + month;
    var dateEvent = year + "-" + month;
    
    final response = await http.get(
      API_EVENTS_CAROUSEL + userLanguage + "&startDate_contains=" + dateEvent,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }
    );

    if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        //print("event: ${jsonResponse[0]}");
        this.futureEvent = jsonResponse.map( (event) => new Event.fromJson(event) ).toList();
        setState(() {
          events.addAll(futureEvent);
        });
        
      return jsonResponse.map( (event) => new Event.fromJson(event) ).toList();
    } else {
      throw Exception('Failed to load events from API');
    }
  }
  
  Future<String> _calculation = Future<String>.delayed(
    Duration(milliseconds: 900),
    () => 'Data Loaded',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top:25),
              child: Text(
                _username.isNotEmpty ? AppLocalizations.of(context).translate("dashboard_title") + ' ${_username[0].toUpperCase()}${_username.substring(1)}' : "",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(82, 59, 92, 1.0),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0,top: 30.0, bottom: 5.0,),
            child: Text(
              AppLocalizations.of(context).translate("dashboard_subtitle"),
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(173, 165, 177, 1.0),
              ),
            ),
          ),
          Divider(color: Colors.grey,),
          SizedBox(height: 20),
            
          FutureBuilder<String>(
            future: _calculation,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              Widget child;
              if (snapshot.hasData) {
                child = CarouselSlider(
                  height: 190.0,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  items: events.map((index) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Padding(
                            padding: EdgeInsets.all(0),
                            child: Column(
                              children: <Widget>[
                                // Title
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)
                                  ),
                                  child: Container(
                                    height: 55,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [Colors.deepPurpleAccent[700], Colors.lightBlue[900]]
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white, blurRadius: 15, offset: Offset(0.0, 2.0)
                                        ),
                                      ],
                                      border: Border(
                                        bottom: BorderSide(width: 1.5, color: Colors.white)
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text('${index.title}',
                                            style: TextStyle(
                                              fontSize: 20, fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Corps
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30)
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => EventDetails(specificEvent: index))
                                      );
                                    },
                                    child: Container(
                                      height: 115,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerRight,
                                          end: Alignment.center,
                                          colors: [Colors.indigo[100], Colors.white]
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          // image
                                          Column(
                                            children: <Widget>[
                                              Flexible(
                                                child: Image(
                                                  image: NetworkImage("${index.image}")
                                                ),
                                              )
                                            ],
                                          ),
                                          // date
                                          Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(top: 5, right: 10),
                                                child: Container(
                                                  child: Text(AppLocalizations.of(context).translate("dashboard_infoDateEvent") + '${index.startDate}',
                                                    style: TextStyle(
                                                      fontSize: 17.5,
                                                      color: Colors.blueGrey[800],
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ),
                                              //icon
                                              Padding(
                                                padding: EdgeInsets.only(top: 13, right: 20),
                                                child: Icon(
                                                  Icons.spa,
                                                  color: Colors.lightGreen[800],
                                                  size: 30.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              } else if (snapshot.hasError) {
                child = Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                );
              } else {
                child = SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                );
              }
              return Center(
                child: child,
              );
            }
          ),

          SizedBox(height: 15),
          Column(
            children: <Widget>[ 
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // click to Awards Card
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 160,
                        height: 160,
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, 'awards');
                          },
                          child: _awardsCard(),
                        ),
                      ),
                      Positioned(
                        left: 90,
                        child: Container(
                          width: 80,
                          height: 80,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/icons/miscellaneous.png"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // click Drawing
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 160,
                        height: 160,
                        margin: EdgeInsets.only(left: 10),
                        padding: EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            Platform.isAndroid ? Navigator.pushNamed(context, "drawingAndroid") :
                            Navigator.pushNamed(context, 'drawing'); // TODO change to drawing
                          },
                          child: _drawingCard(),
                        ),
                      ),
                      Positioned(
                        left: 90,
                        top: 10,
                        child: Container(
                          width: 80,
                          height: 80,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/icons/drawing.png"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}