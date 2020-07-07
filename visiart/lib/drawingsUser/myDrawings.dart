import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Drawing.dart';
import 'package:transparent_image/transparent_image.dart';

class MyDrawings extends StatefulWidget {
  @override
  _MyDrawingsState createState() => _MyDrawingsState();
}

class _MyDrawingsState extends State<MyDrawings> {

  List<Drawing> allDrawings = List<Drawing>();

  @override
  void initState() {
    _fetchDrawings();
    super.initState();
  }
  
  void _fetchDrawings() async {
    var token = await SharedPref().read("token");

    final response = await http.get(API_DRAWINGS, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      var all = jsonResponse.map((draw) => Drawing.fromJson(draw)).toList();
      setState(() {
        allDrawings.addAll(all);
      });
    } else {
      throw Exception('Failed to load drawings from API');
    }
  }

  _openImage(context, index) async {

    final _content = allDrawings[index].urlImage;
    final _start = _content.indexOf("img_") + "img_".length;
    final _dateDraw = _content.substring(_start, 98);

    showDialog(
      context: context,
      builder: (el) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate("myDrawings_infoDate") + "$_dateDraw", 
          textAlign: TextAlign.center,
        ),
        content: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage, 
          image: allDrawings[index].urlImage),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).translate("close"))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
        title: Text(AppLocalizations.of(context).translate("myDrawings_title")),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: GridView.builder(
          itemCount: allDrawings.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: allDrawings[index].urlImage),
                onTap: () {
                  _openImage(context, index);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}