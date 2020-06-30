import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:visiart/models/Event.dart';
import 'package:permission/permission.dart';

//void main() => runApp(EventMaps());

class EventMaps extends StatelessWidget {
  final List<double> coordinate;

  EventMaps({Key key, @required this.coordinate}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'You are...',
      home: EventMapsPage(coordinate: coordinate),
    );
  }
}

class EventMapsPage extends StatefulWidget {
  final List<double> coordinate;
  EventMapsPage({Key key, @required this.coordinate}) : super(key: key);

  @override
  State<EventMapsPage> createState() => EventMapsPageState(coordinate);
}

class EventMapsPageState extends State<EventMapsPage> {
  Completer<GoogleMapController> _controller = Completer();

  List<double> coordinate;
  CameraPosition _cameraPosition;
  List<Marker> markers = <Marker>[];
  
  /* CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746
  ); */

  EventMapsPageState(List<double> coordinate) {

    this.coordinate = coordinate;
      _cameraPosition = CameraPosition(
      target: LatLng(coordinate.last, coordinate.first),
      zoom: 18
    );

    markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: LatLng(coordinate.last, coordinate.first),
        onTap: () {},
      ),
    );
  }

@override
  void initState() {
    
    /* setState(() {
      _cameraPosition = CameraPosition(
        target: LatLng(coordinate.first, coordinate.last),
        zoom: 14.4746,
      );
    }); */
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: _cameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(markers),
        ),
      );
  }
}