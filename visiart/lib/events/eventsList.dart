import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class EventsListScreen extends StatefulWidget {
  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {

  String name, username, avatar;
  bool isData = false;

  /*
  * EXEMPLE : API GET PARSE JSON
  */
  /*FetchJSON() async {
    var Response = await http.get(
      "https://api.github.com/users/nitishk72",
      headers: {"Accept": "application/json"},
    );

    if (Response.statusCode == 200) {
      String responseBody = Response.body;
      var responseJSON = json.decode(responseBody);
      username = responseJSON['login'];
      name = responseJSON['name'];
      avatar = responseJSON['avatar_url'];
      isData = true;
      setState(() {
        print('UI Updated');
      });
    } else {
      print('Something went wrong. \nResponse Code : ${Response.statusCode}');
    }
  }*/

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
                color: Colors.red[100 * (index % 10)],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[                
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 12, bottom: 10, left: 12),
                                  child: Text("TITLE EVENT $index",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10, left: 12),
                            child: Text("Description event : aaaaaaaaaaaaaaaaa",
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
