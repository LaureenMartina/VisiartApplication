import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SaveImage extends StatefulWidget {
  @override
  _SaveImageState createState() => _SaveImageState();
}

class _SaveImageState extends State<SaveImage> {
  GlobalKey _globalKey = GlobalKey();
  bool _loading = false;

  void _convertAndSaveDrawing() async {
    RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 1);
    // final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);

    setState(() {
      _loading = true;
    });

    String fileName = "IMG_51/img_${DateTime.now().millisecondsSinceEpoch}.png";
    StorageReference storageReference = FirebaseStorage().ref().child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putData(pngBytes);
    
    await storageUploadTask.onComplete;

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            RepaintBoundary(
              key: _globalKey,
              child:Container(
                child: Column(
                  children: <Widget>[
                    Text("tesssst screenshot"),
                    Container(color: Colors.red,),
                    (_loading) ? Center(child: CircularProgressIndicator()) : Center()
                  ],
                ),
              ),
            ),
            MaterialButton(
              color: Colors.orange,
              child: Text('photo'),
              onPressed: () {
                _convertAndSaveDrawing();
              },
            ),
          ],
        )
      ),
    );
  }
}