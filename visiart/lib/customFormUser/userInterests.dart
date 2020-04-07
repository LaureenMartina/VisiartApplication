import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:progress_button/progress_button.dart';
import 'package:visiart/dashboard/dashboard.dart';


class UserInterestsScreen extends StatefulWidget {
  @override
  _UserInterestsScreenState createState() => _UserInterestsScreenState();
}

class _UserInterestsScreenState extends State<UserInterestsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[200],
        brightness: Brightness.light,
        elevation: 2,
        title: Text('Vos Centres d\'intérêts', style: TextStyle(color: Colors.black87),),
      ),
      body: _bodyScreen(context),
      backgroundColor: Colors.grey[200],
    );
  }
}

Widget _bodyScreen(BuildContext context) {
  bool _switchValue = false;

  final divider = Divider(
    color: Colors.black38,
    indent: 30,
    endIndent: 30,
  );

  List<String> nameChips = [
    "Museum", "Exposition", "Cinema", "Painting", "Athletic Event", "Music", "Concert",
    "Dance", "Modern Art", "Theater", "Drawing", "Design", "Literature", "Spectacle", "Photography",
  ];

  void _navigateToDashboardScreen() {
    //Navigator.pushNamed(context, '/new');
    Navigator.pushReplacement(
        context, MaterialPageRoute(
        builder: (BuildContext context) => DashboardScreen() )
    );
  }

  return CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Container(
          height: 100,
          child: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text("Dites nous ce que vous aimez",
                style: TextStyle(
                    color: Colors.deepOrange[200],
                    fontSize: 25,
                    letterSpacing: 2.5
                ),
                textAlign: TextAlign.center
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          height: 40,
          child: Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Text("Sélectionnez un ou plusieurs domaines qui vous intéressent",
                style: TextStyle(color: Colors.black87, fontSize: 14)
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          height: 250,
          child: Padding(
            padding: EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Wrap(
                  children: [
                    for (var name in nameChips)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        child: CreateFilterChip(chipName: name),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
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
                alignment: Alignment.centerRight,
                child: Switch(
                  value: _switchValue,
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    //setState(() {
                    // TODO setState not working
                      _switchValue = value;
                      print(_switchValue);
                    //});
                  },
                ),
              )
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 30, top: 10),
          child: ProgressButton(
            child: Text("Enregistrer",
              style: TextStyle(color: Colors.black87, fontSize: 18),
            ),
            buttonState: ButtonState.normal,
            backgroundColor: Colors.deepOrange[200],
            onPressed: () {
              // TODO progess button
              _navigateToDashboardScreen();
            },
            progressColor: Colors.deepOrange[300],
          ),
        ),
      ),
    ],
  );
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