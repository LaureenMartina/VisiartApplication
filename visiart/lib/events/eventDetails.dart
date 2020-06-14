import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/models/Event.dart';

SharedPref sharedPref = SharedPref();

class EventDetails extends StatefulWidget {
    final Event specificEvent;

    EventDetails({Key key, @required this.specificEvent}) : super(key: key);

    @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {

  var infoSite = "Plus d'informations sur le site officiel";
  var infoGeoloc = "Où ?";
  var favorite = false;
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
      if (favorite) {
        favorite = false;
      } else {
        favorite = true;
        // TODO: update API EVENT
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //print("eventDetails: ${widget.specificEvent.id}");
    var city = widget.specificEvent.city;

    return Scaffold(
      //backgroundColor: Colors.white,
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
                      backgroundColor: Colors.red[50], 
                      child: IconButton(
                        icon: (favorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border)),
                        color: Colors.red[500],
                        iconSize: 35,
                        onPressed: _changeFavorite,
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
                            ),
                          )
                          : Text(
                              "France",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                        SizedBox(width: 200,),
                        RaisedButton.icon(
                          icon: Icon(Icons.room),
                          label: Text(infoGeoloc,
                            style: TextStyle(
                              fontSize: 16
                            ),
                          ),
                          elevation: 5,
                          //color: Colors.deepOrange[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                          ),
                          onPressed: () => {}
                        ),
                      ],
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
                            "Début : ${widget.specificEvent.startDate}", 
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                            ),
                          ),
                          alignment: Alignment.center,
                          width: 180,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[900],
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
                          child: Text("Fin : ${widget.specificEvent.endDate}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16
                            ),
                          ),
                          alignment: Alignment.center,
                          width: 180,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[900],
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
                          color: Colors.deepOrange[100],
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