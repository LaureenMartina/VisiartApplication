import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/events/eventMaps.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Event.dart';
import 'package:http/http.dart' as http;

SharedPref sharedPref = SharedPref();

class EventDetails extends StatefulWidget {
    final Event specificEvent;

    EventDetails({Key key, @required this.specificEvent}) : super(key: key);

    @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {

  var infoSite = "Plus d'informations sur le site officiel";
  //var infoGeoloc = "";
  var _favorite = false;
  int _idEvent;
  var specificEvent = List<Event>();
  Future<void> _launchedUrlSite(url) async {
    if(await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: true);
    }else{
      print("error open url");
    }
  }

  void _changeFavorite() {
    setState(() {
      if (_favorite) {
        _favorite = false;
      } else {
        _favorite = true;
        _setFavoriteEvent();
      }
    });
  }

  void _setFavoriteEvent() async{
    var token = await sharedPref.read(API_TOKEN_KEY); 
    final response = await http.put("http://91.121.165.149/events/" + _idEvent.toString(),
      headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, bool>{
        'favorite' : true
      }),
    );
    print("response: $response");
    
    if(response.statusCode == 200) {
        print(response.statusCode);
    } else {
      throw Exception('Failed to update event in API');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("id: ${widget.specificEvent.id}");
    String city = widget.specificEvent.city;
    String urlSite = widget.specificEvent.urlSite;
    _idEvent = widget.specificEvent.id;
    bool favoriteEvent = widget.specificEvent.favorite;
    if(favoriteEvent == null) favoriteEvent = false;
    print(favoriteEvent);
    //print("geoJson: ${widget.specificEvent.geoJson}");

    return Scaffold(
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 370,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0.0, 2.0)
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)
                  ),
                  child: Image(
                    image: NetworkImage("${widget.specificEvent.image}"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Back Arrow
                    IconButton(
                      icon: Icon(Icons.arrow_back), 
                      iconSize: 30,
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context)
                    ),
                    // Favorite Btn
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white70, 
                      child: IconButton(
                        icon: (favoriteEvent) ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                        color: Colors.red[500],
                        iconSize: 35,
                        onPressed: () {
                          _changeFavorite();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Title
                    Flexible( 
                      flex: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        width: 310,
                        margin: EdgeInsets.all(0),
                        child: Text(
                          "${widget.specificEvent.title}",
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    //City
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(
                          Icons.location_city,
                          color: Colors.white,
                        ),
                        
                      SizedBox(width: 8),
                      (city != "") ?
                        Text(
                          "${widget.specificEvent.city}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                          ),
                        )
                        : Text(
                          "France",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ), 
                  ],
                ),
              ),
              // btn Géolocalisation
              Positioned(
                top: 105,
                left: 314,
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.white70,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        iconSize: 35,
                        icon: Icon(Icons.room),
                        color: Colors.green[900],
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventMaps(coordinate: widget.specificEvent.geoJson, eventName: widget.specificEvent.title)
                            )
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // dates + Description
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        // start Date
                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Text(
                            AppLocalizations.of(context).translate("eventDetail_from") + " ${widget.specificEvent.startDate}", 
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                            ),
                          ),
                          alignment: Alignment.center,
                          width: 180,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(173, 165, 177, 1.0),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                        ),
                        // endDate
                        Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Text(AppLocalizations.of(context).translate("eventDetail_to") + " ${widget.specificEvent.endDate}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                            ),
                          ),
                          alignment: Alignment.center,
                          width: 180,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(173, 165, 177, 1.0),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15,),
                    // Description
                    Flexible( 
                      flex: 0,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
                        //height: 210,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 14),
                          child: Text("${widget.specificEvent.longDescription}",
                            //overflow: TextOverflow.ellipsis,
                            maxLines: 30,
                            style: TextStyle(
                              wordSpacing: 1.2,
                              letterSpacing: 1,
                              height: 1.4
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8,),
                    //url site
                    if (urlSite != "")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton.icon(
                            icon: Icon(Icons.visibility),
                            label: Text(
                              infoSite,
                              style: TextStyle(
                                fontSize: 16
                              ),
                            ),
                            elevation: 5,
                            color: Color.fromRGBO(252, 233, 216, 1.0),
                            colorBrightness: Brightness.light,
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                            ),
                            onPressed: () => {
                              _launchedUrlSite("${widget.specificEvent.urlSite}")
                            }
                          ),
                        ],
                      ),
                    SizedBox(height: 35,),
                  ],
                );
              },
            ),
          ),
        ],
      )
    );
  }
}