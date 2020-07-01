import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:loading/loading.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/models/Event.dart';
import 'package:visiart/awardsUser/awardsList.dart';
import 'package:visiart/drawingsUser/drawing.dart';

SharedPref sharedPref = SharedPref();

class DashboardScreen extends StatefulWidget {

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> nameCards = ["Trophées", "Dessins"]; // TODO Translate
  var infoDate = "A partir du \n";
  //bool isLoaded = false;
  
  var events = List<Event>();
  List<Event> futureEvent;

  @override
  void initState() {
    // if(!isLoaded) {
    //   _delayedDataEvent();
    //   initState();
    // }else{
    //   //initState();
    // }
    _fetchEvents();
    super.initState();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }


  // void _delayedDataEvent() {
  //   print("1 load: $isLoaded");
  //   Future.delayed(Duration(milliseconds: 800), () {
  //     isLoaded = true;
  //     print("2 load: $isLoaded");
  //   } );
  // }

  final getNameUser = Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: EdgeInsets.only(top:20),
      child: Text(
        'Bonjour USER',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.teal[300],
        ),
      ),
    ),
  );

  final titleCalendarOfActivities = Container(
    margin: const EdgeInsets.only(
      left: 16.0,top: 24.0, bottom: 5.0,
    ),
    child: Text(
      'Calendrier de vos Activités',
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: Colors.teal[300],
      ),
    ),
  );

  final sliderCalendarActivity = Container(
    height: 80.0,
    //color: Colors.greenAccent,
    child: Padding(
      padding: EdgeInsets.only(left: 15),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(10, (int index) {
          return Card(
            color: Colors.blue[index * 100],
            child: Container(
              width: 90.0,
              height: 60.0,
              child: Text("$index"),
            ),
          );
        }),
      ),
    ),
  );

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
          Text("Vos Trophées", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
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
      padding: EdgeInsets.only(top:55, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Vos\nDessins AR", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
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
      API_EVENT_CAROUSEL + userLanguage + "&startDate_contains=" + dateEvent,
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
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          getNameUser,
          titleCalendarOfActivities,
          Divider(color: Colors.grey,),
          sliderCalendarActivity,
          SizedBox(height: 10),
          
          DelayedDisplay(
            delay: Duration(milliseconds: 100),
            fadingDuration: Duration(milliseconds: 500),
            slidingBeginOffset: const Offset(0.0, 0),
            child: CarouselSlider(
              height: 160.0,
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
                                height: 48,
                                decoration: BoxDecoration(
                                  //color: Colors.lightBlue[800],
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
                                          fontSize: 18, fontWeight: FontWeight.bold,
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
                              child: Container(
                                height: 110,
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
                                          padding: EdgeInsets.only(top: 5, right: 15.0),
                                          child: Container(
                                            child: Text(infoDate + '${index.startDate}',
                                              style: TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey[800],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // icon
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
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
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
                  // click AlertCard
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