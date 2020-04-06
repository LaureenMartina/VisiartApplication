import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class UserInterestsScreen extends StatefulWidget {
  @override
  _UserInterestsScreenState createState() => _UserInterestsScreenState();
}

class _UserInterestsScreenState extends State<UserInterestsScreen> {

  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {

    List<String> nameChips = [
      "Museum", "Exposition", "Cinema", "Painting", "Athletic Event", "Music", "Concert",
      "Dance", "Modern Art", "Theater", "Drawing", "Design", "Literature", "Spectacle", "Photography",
    ];

    final divider = Divider(
      color: Colors.black38,
      indent: 30,
      endIndent: 30,
    );

    final switchAvailableUser = Container(
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15, right: 40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Etes-vous prêt(e) à vous déplacer ?"),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            child: Switch(
              value: _switchValue,
              onChanged: (value) {
                setState(() {
                  _switchValue = value;
                  print(_switchValue);
                });
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Vos Centres d\'intérêts'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text("Dites nous ce que vous aimez",
              style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 25,
                  letterSpacing: 2.5
              ),
              textAlign: TextAlign.center
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 20.0),
            child: Text("Sélectionnez un ou plusieurs domaines qui vous intéressent",
                style: TextStyle(color: Colors.black87, fontSize: 14)
            ),
          ),
          SizedBox(height: 5.0),
          divider,
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Wrap(
                  children: [
                    for (var name in nameChips)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: CreateFilterChip(chipName: name),
                    )
                  ],
                ),
              ),
            ),
          ),
          divider,
          switchAvailableUser,
        ],
      ),
    );
  }
}

class CreateFilterChip extends StatefulWidget {
  final String chipName;

  CreateFilterChip({Key key, this.chipName}) : super(key: key);

  @override
  _createFilterChipState createState() => _createFilterChipState();
}

class _createFilterChipState extends State<CreateFilterChip> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.chipName),
      selected: isSelected,
      selectedColor: Colors.green,
      onSelected: (value) {
        setState(() {
          isSelected = value;
        });
      },
    );
  }
}