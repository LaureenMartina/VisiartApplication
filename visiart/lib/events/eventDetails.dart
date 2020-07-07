import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/events/eventMaps.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Event.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/models/UserEventFavorite.dart';

SharedPref sharedPref = SharedPref();

class EventDetails extends StatefulWidget {
    final Event specificEvent;

    EventDetails({Key key, @required this.specificEvent}) : super(key: key);

    @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {

  var _favorite = false;
  int _idEvent, _idUserEventFavorite;

  List<Event> specificEvent = List<Event>();
  List<UserEventFavorite> _getAllFavorite = List<UserEventFavorite>();
  List<UserEventFavorite> _allFavoriteEvents = List<UserEventFavorite>();

  @override
  void initState() {
    _getFavoriteEvent();
    super.initState();
  }

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
        _removeFavoriteEvent();
      } else {
        _favorite = true;
        _setFavoriteEvent(_favorite);
      }
    });
  }

  void _getFavoriteEvent() async {
    String token = await sharedPref.read(API_TOKEN_KEY);
    int userId = await sharedPref.readInteger("userId");

    final response = await http.get(API_USER_EVENT_FAVORITES_USERID + userId.toString(),
      headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
      }
    );
    
    if(response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        _getAllFavorite.addAll(
            jsonResponse.map((favori) => new UserEventFavorite.fromJson(favori)).toList());
        _allFavoriteEvents.addAll(_getAllFavorite);
      });

    } else {
      throw Exception('Failed to get all user-event-favorite in API');
    }
  }
  
  void _setFavoriteEvent(changeFavorite) async{
    String token = await sharedPref.read(API_TOKEN_KEY);
    int userId = await sharedPref.readInteger("userId");

    var data = {
      "user": {
        "id": userId
      },
      "event": {
        "id": _idEvent
      },
      'favorite' : true 
    };

    final response = await http.post(API_USER_EVENT_FAVORITES,
      headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    
    if(response.statusCode == 200) {
      //print(response.statusCode);
    } else {
      throw Exception('Failed to create user-event-favorite in API');
    }
  }

  void _removeFavoriteEvent() async {
    String token = await sharedPref.read(API_TOKEN_KEY);

    if(_allFavoriteEvents != []) {
      for(int i = 0; i < _allFavoriteEvents.length; i++){
        if(_allFavoriteEvents[i].event.id == _idEvent && _allFavoriteEvents[i].favorite == true) {
          print("id : ${_allFavoriteEvents[i].id}");
          _favorite = false;
          _idUserEventFavorite = _allFavoriteEvents[i].id;
        }
      }
    }

    final response = await http.delete(API_USER_EVENT_FAVORITES + "/" + _idUserEventFavorite.toString(),
      headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
      }
    );
    
    if(response.statusCode == 200) {
      //print(response.statusCode);
    } else {
      throw Exception('Failed to delete user-event-favorite in API');
    }
  }

  @override
  Widget build(BuildContext context) {
    //print("id: ${widget.specificEvent.id}");
    String city = widget.specificEvent.city;
    String urlSite = widget.specificEvent.urlSite;
    _idEvent = widget.specificEvent.id;
    List<double> geoJson = widget.specificEvent.geoJson;
    
    if(_allFavoriteEvents != []) {
      for(int i = 0; i < _allFavoriteEvents.length; i++){
        if(_allFavoriteEvents[i].event.id == _idEvent && _allFavoriteEvents[i].favorite == true) {
          _favorite = true;
        }else{
          _favorite = false;
        }
      }
    }

    return 
    Scaffold(
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
                        icon: (_favorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border)),
                        color: Colors.red[500],
                        iconSize: 35,
                        onPressed: () {
                          setState(() {
                            _changeFavorite();
                          });
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
              // Géolocalisation Btn
              if(geoJson.length != 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 110),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Material(
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
                    ],
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
                              AppLocalizations.of(context).translate("eventDetail_linkEvent"),
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