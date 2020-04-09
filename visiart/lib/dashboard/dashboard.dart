import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:getflutter/getflutter.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  List<String> nameCards = ["Trophées", "Dessins"];

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
    height: 120.0,
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

  final cardTrophees = GestureDetector(
    onTap: () {
      print("Container clicked");
    },// handle your onTap here
    child: Padding(
        padding: EdgeInsets.only(left: 20),
        child: SizedBox(
          height: 130,
          width: 130,
          child: Card (
            color: Colors.greenAccent,
            child: Text('Trophées'),
          ),
        )
    ),
  );

  final cardAlerts = GestureDetector(
    onTap: () {
      print("Container clicked");
    },// handle your onTap here
    child: Padding(
        padding: EdgeInsets.only(left: 20),
        child: SizedBox(
          height: 130,
          width: 130,
          child: Card (
            color: Colors.greenAccent,
            child: Text('Dessins AR'),
          ),
        )
    ),
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
          ),
          Container(
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
          ),
          Divider(color: Colors.grey,),
          sliderCalendarActivity,
          SizedBox(height: 15,),
          carouselActuality,
          SizedBox(height: 15,),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Row(
              children: <Widget>[
                cardTrophees,
                cardAlerts,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/*
height: 130.0,
            color: Colors.greenAccent,
            child: Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(2, (int index) {
                  return Card(
                    color: Colors.blue,
                    child: Container(
                      width: 130.0,
                      height: 130.0,
                      child: Text('${nameCards[index]}'),
                    ),
                  );
                }),
              ),
            ),
 */