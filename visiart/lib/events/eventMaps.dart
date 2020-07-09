import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:location/location.dart' as loc;

class EventMaps extends StatefulWidget {
  final List<double> coordinate;
  final String eventName;

  EventMaps({Key key, @required this.coordinate, @required this.eventName}) : super(key: key);

  @override
  State<EventMaps> createState() => EventMapsState(coordinate, eventName);
}


class EventMapsState extends State<EventMaps> {
  Completer<GoogleMapController> _controller = Completer();

  List<double> coordinate;
  String eventName;
  CameraPosition _cameraPosition;
  List<Marker> _markers = <Marker>[];
  BitmapDescriptor _userIcon;
  loc.PermissionStatus _permissionGranted;
  bool _serviceEnabled;
  loc.Location location;
  
  EventMapsState(List<double> coordinate, String eventName) {
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

  _askPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

    _permissionGranted = await location.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          return;
        }
      }
  }

  @override
  void initState() {
    _askPermissions();
    _getLocation();
    _getValidMakerIcon().then((value) => {
      _userIcon = BitmapDescriptor.fromBytes(value)
    });
    super.initState();
  }

  Future<Uint8List> _getValidMakerIcon() async {
    ByteData data = await rootBundle.load("assets/icons/me.png");
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 80);
    ui.FrameInfo fi = await codec.getNextFrame();
    
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void _getLocation() async {
    var currentLocation = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
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
    return MaterialApp(
      //title: 'You are...',
      home: 
      Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.terrain,
              initialCameraPosition: _cameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: Set<Marker>.of(_markers),
            ),
            IconButton(
              icon: Icon(Icons.arrow_back), 
              iconSize: 30,
              color: Colors.black,
              onPressed: () => Navigator.pop(context)
            ),  
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}