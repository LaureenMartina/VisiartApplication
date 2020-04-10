import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class EventsListScreen extends StatefulWidget {
  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Container(
                alignment: Alignment.center,
                height: 180,
                child: Text('event $index'),
                color: Colors.orange[100 * (index % 10)],
              );
            }, childCount: 10,
            ),
          ),
        ],
      ),
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
