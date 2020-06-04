import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:visiart/awardsUser/modalAwards.dart';
import 'package:visiart/config/config.dart' as globals;

class DashboardScreen extends StatefulWidget {

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //var isEnabled = globals.curiousBadgeEnabled;
  List<String> nameCards = ["Trophées", "Dessins"];

  /*@override
  void initState() {
    super.initState();
    //_triggerAwards();
  }

  void _triggerAwards() {
    setState(() {
      print("Hello popup !!");
      if(isEnabled) ModalAwards();
    });
  }*/

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
    color: Colors.greenAccent,
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

  final carouselActuality = CarouselSlider(
    height: 150.0,
    initialPage: 0,
    enableInfiniteScroll: true,
    reverse: false,
    autoPlay: false,
    //autoPlayInterval: Duration(minutes: 1),
    //autoPlayAnimationDuration: Duration(milliseconds: 1000),
    //autoPlayCurve: Curves.fastOutSlowIn,
    items: [1,2,3,4,5].map((i) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(30.0),
                  topRight: const Radius.circular(30.0),
                  bottomLeft: const Radius.circular(30.0),
                  bottomRight: const Radius.circular(30.0)
              ),
            ),
            child: Text('text $i',
              style: TextStyle(fontSize: 16.0,),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    }).toList(),
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
      padding: EdgeInsets.only(top:60, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Vos \nDessins AR", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4),
        ],
      ),
    ),
  );


  @override
  Widget build(BuildContext context) {
    //_triggerAwards();
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          getNameUser,
          titleCalendarOfActivities,
          Divider(color: Colors.grey,),
          sliderCalendarActivity,
          SizedBox(height: 20),
          carouselActuality,
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
                            /*Navigator.push(
                              context, MaterialPageRoute(
                                builder: (BuildContext context) => AwardsListScreen() )
                            );*/
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
                            Navigator.pushNamed(context, 'awards'); // TODO change to drawing
                            /*Navigator.push(
                              context, MaterialPageRoute(
                                builder: (BuildContext context) => AwardsListScreen() )
                            );*/
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