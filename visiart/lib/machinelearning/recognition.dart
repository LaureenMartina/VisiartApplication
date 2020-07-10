import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:visiart/chatRooms/roomChats.dart';
import 'package:visiart/chatRooms/roomCreate.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/Room.dart';
import 'package:visiart/utils/AlertUtils.dart';

class PaintingRecognitionScreen extends StatefulWidget {
  @override
  _PaintingRecognitionScreenState createState() =>
      _PaintingRecognitionScreenState();
}

class _PaintingRecognitionScreenState extends State<PaintingRecognitionScreen> {
  File _image;
  String _painter = "";
  final picker = ImagePicker();

  BuildContext ctx;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
      _painter = AppLocalizations.of(ctx).translate("ml_calculating");
    });

    final imageBytes = File(pickedFile.path).readAsBytesSync();

    String imgBytesStr = base64Encode(imageBytes);

    Map data = {"image": imgBytesStr};
    String token = await SharedPref().read("token");
    http
        .post(
      API_ML,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(data),
    )
      .then((response) {
        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          Room room;
          if (jsonResponse.containsKey('room')) {
            room = new Room.fromJson(jsonResponse['room']);
          }
          setState(() {
            _painter = jsonResponse['painter'];
          });
          bool roomAlreadyExist = jsonResponse['roomAlreadyExists'];
          String alertBody;
          if (roomAlreadyExist) {
            alertBody = AppLocalizations.of(ctx).translate("ml_goToRoom");
          } else {
            alertBody = AppLocalizations.of(ctx).translate("ml_createRoom");
          }

          showAlert(
            ctx,
            _painter,
            alertBody,
            AppLocalizations.of(ctx).translate("yes"),
            () {
              if (roomAlreadyExist) {
                Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (BuildContext context) => RoomsChatPage(
                        room: room,
                      )));
              } else {
                Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (BuildContext context) => RoomsCreateScreen(
                              defaultRoomName: _painter,
                            )));
              }
            },
            AppLocalizations.of(ctx).translate("no"),
          );
        } else {
          setState(() {
            _painter = AppLocalizations.of(ctx).translate("none");
          });
        }

        
    });
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
          brightness: Brightness.light,
          elevation: 2,
          title: Text(
            AppLocalizations.of(context).translate('userInterest_userInterest'),
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                Text(_painter),
                SizedBox(height: 20),
                _image == null ? Text(AppLocalizations.of(context).translate("ml_noImage")) : Image.file(_image),
          ],
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: getImage,
          tooltip: 'Pick Image',
          child: Icon(Icons.add_a_photo),
        ));
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  void reco() async {}

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    reco();
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
