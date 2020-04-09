import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/cupertino.dart';

class EventsListScreen extends StatefulWidget {
  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      /*primary: false,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.only(left: 0, right: 0),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            children: <Widget>[
              Align(
                child: CupertinoButton(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/imgs/pattern.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                      child: Text(
                        "Trophées",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  onPressed: () {
                    print(Text('hello'));
                  },
                ),
              ),
              Align(
                child: CupertinoButton(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/imgs/pattern.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                      child: Text(
                        "Trophées",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  onPressed: () {
                    print(Text('hello'));
                  },
                ),
              ),
              Align(
                child: CupertinoButton(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/imgs/pattern.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                      child: Text(
                        "Trophées",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  onPressed: () {
                    print(Text('hello'));
                  },
                ),
              ),
              Align(
                child: CupertinoButton(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/imgs/pattern.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
                      child: Text(
                        "Trophées",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  onPressed: () {
                    print(Text('hello'));
                  },
                ),
              ),
            ],
          ),
        ),
      ],*/
    );
  }
}
