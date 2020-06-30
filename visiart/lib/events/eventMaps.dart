import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:visiart/models/Event.dart';
import 'package:permission/permission.dart';
import 'dart:ui' as ui;

//void main() => runApp(EventMaps());

class EventMaps extends StatelessWidget {
  final List<double> coordinate;
  final String eventName;

  EventMaps({Key key, @required this.coordinate, @required this.eventName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'You are...',
      home: EventMapsPage(coordinate: coordinate, eventName: eventName),
    );
  }
}

class EventMapsPage extends StatefulWidget {
  final List<double> coordinate;
  final String eventName;
  EventMapsPage({Key key, @required this.coordinate, @required this.eventName}) : super(key: key);

  @override
  State<EventMapsPage> createState() => EventMapsPageState(coordinate, eventName);
}

class EventMapsPageState extends State<EventMapsPage> {
  Completer<GoogleMapController> _controller = Completer();

  List<double> coordinate;
  String eventName;
  CameraPosition _cameraPosition;
  List<Marker> _markers = <Marker>[];
  BitmapDescriptor _userIcon;
  
  /* CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746
  ); 
  48.8647135,2.3450413
  */

  EventMapsPageState(List<double> coordinate, String eventName) {

    this.coordinate = coordinate;
      _cameraPosition = CameraPosition(
      target: LatLng(coordinate.last, coordinate.first),
      zoom: 18
    );
    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: LatLng(coordinate.last, coordinate.first),
        //icon: value,
        infoWindow: InfoWindow(title: eventName),
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
    _getLocation();
    _getValidMakerIcon().then((value) => {
      print("init staste"),
      print(value),
      _userIcon = BitmapDescriptor.fromBytes(value)
    });
    super.initState();
  }

  Future<Uint8List> _getValidMakerIcon() async {
    ByteData data = await rootBundle.load("assets/icons/me.png");
    print("get valid");
    print(data);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 60);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  
  }

  void _getLocation() async {
      var currentLocation = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      print("icon");
      print(_userIcon.toString());
      setState(() {
        var marker = Marker(
            markerId: MarkerId("curr_loc"),
            position: LatLng(currentLocation.latitude, currentLocation.longitude),
            icon: _userIcon,
            infoWindow: InfoWindow(title: 'Vous êtes ici !'),
        );
        this._markers.add(marker);
      });
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
        markers: Set<Marker>.of(_markers),
        ),
      );
  }
}