import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';

enum SelectedMode { StrokeWidth, Opacity, Color, Object3D, Material }

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {

  GlobalKey _globalKey = GlobalKey();
  // final String screenshotImagePath = '/screenshots';

  ARKitController arkitController;

  String _animationState = "simple";

  bool detectAR = false;
  bool changed = false;
  bool modernObj = false;
  bool showBottomList = false;

  ARKitNode nodeSphere, nodeCube, nodeCone, nodeCylinder, nodePyramid, nodeTorus, nodeText;

  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  Color color = Colors.yellow;

  double strokeWidth = 5.0;
  double opacity = 1.0;
  
  String selectedObj = "cube";
  String selectedMaterial = "";

  List<DrawingPoints> points = List();

  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;

  List<Color> colors = [
    Colors.red,
    Colors.pink[100],
    Colors.pink,
    Colors.green,
    Colors.teal[900],
    Colors.blue,
    Colors.indigo[900],
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.white,
    Colors.grey,
    Colors.black
  ];

  Map<String,String> obj3D = {
    "sphere": "assets/imgs/sphere.png",
    "cube": "assets/imgs/cube.png",
    "cone": "assets/imgs/cone.png",
    "cylinder": "assets/imgs/cylinder.png",
    "pyramid": "assets/imgs/pyramid.png",
    "torus": "assets/imgs/torus.png",
    "text": "assets/imgs/text.png"
  };

  List<String> materialsLink = [
    "assets/imgs/art.png",
    "assets/imgs/brique.png",
    "assets/imgs/carte.png",
    "assets/imgs/cartoon.png",
    "assets/imgs/citrus.png",
    "assets/imgs/ecailles.png",
    "assets/imgs/happy.png",
    "assets/imgs/hexagone.png",
    "assets/imgs/leaf.png",
    "assets/imgs/lotus.png",
    "assets/imgs/mosaique.png",
    "assets/imgs/sun.png",
    "assets/imgs/wave.png",
    "assets/imgs/zebre.png"
  ];

  void _counterAnimation() {
    setState(() {
      if(_animationState == "simple") {
         _animationState = "ar";
         detectAR = true;
         print("detectAR $detectAR");
      }else{
        _animationState = "simple";
        detectAR = false;
        print("detectAR $detectAR");
      }
    });
  }

  /*=====================================================*/
  _getColorList() {
    List<Widget> listWidget = List();

    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }

    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0, top: 20),
          height: 40,
          width: 40,
          color: color,
        ),
      ),
    );
  }

  _getObject3D() {
    List<Widget> listWidget = List();

    obj3D.forEach((nameObj, path) {
      listWidget.add(object3DDisplay(nameObj, path));
    });

    return listWidget;
  }

  Widget object3DDisplay(String nameObj, String path) {
    return GestureDetector(
      onTap: () {
        setState(() {
          print("changed: $changed");
          changed = true;
          selectedObj = nameObj;
          print("object cliqué: $selectedObj");
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0, top: 20),
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(path)
            ),
          ),
        ),
      ),
    );
  }

  _getMaterials() {
    List<Widget> listWidget = List();

    for(var link in materialsLink) {
      listWidget.add(materialsDisplay(link));
    }

    return listWidget;
  }

  Widget materialsDisplay(String path) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMaterial = path;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0, top: 20),
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(path)
            ),
          ),
        ),
      ),
    );
  }

  /*=====================================================*/

  _onArKitViewCreated(ARKitController controller, String obj, String decor) {
    this.arkitController = controller;
    
    ARKitMaterial material = ARKitMaterial(
      diffuse: ARKitMaterialProperty(image: decor),
    );
    
    print("choice: $obj");
    print("decor: $decor");

    switch (obj) {
      case "sphere": {
          print("sphere"); 
          nodeSphere = ARKitNode(
            geometry: ARKitSphere(
              radius: 0.2,
              materials: [material]
            ),
            position: vector.Vector3(0, 0, -0.5),
          );

          //this.arkitController.remove(nodeCube.name);
          this.arkitController.add(nodeSphere);
        }
        break;
      case "cone": {
          print("cone");
          nodeCone = ARKitNode(
            geometry: ARKitCone(
              topRadius: 0,
              bottomRadius: 0.10,
              height: 0.18,
              materials: [material],
            ),
            position: vector.Vector3(0, -0.1, -0.5),
          );

          this.arkitController.add(nodeCone);
        }
        break;
      case "cylinder": {
        print("test cylindre");
        nodeCylinder = ARKitNode(
          geometry: ARKitCylinder(
            radius: 0.08,
            height: 0.15,
            materials: [material],
          ),
          position: vector.Vector3(0, -0.1, -0.5),
        );

        this.arkitController.add(nodeCylinder);
      }
        break;
      case "pyramid": {
        print("test pyramide");
        nodePyramid = ARKitNode(
          geometry: ARKitPyramid(
            width: 0.20,
            height: 0.20,
            length: 0.20,
            materials: [material],
          ),
          position: vector.Vector3(0, -0.05, -0.5),
        );

        this.arkitController.add(nodePyramid);
      }
        break;
      case "torus": {
        print("test donut");
        nodeTorus = ARKitNode(
          geometry: ARKitTorus(
            ringRadius: 0.04,
            pipeRadius: 0.02,
            materials: [material],
          ),
          position: vector.Vector3(0.1, -0.1, -0.5),
        );

        this.arkitController.add(nodeTorus);
      }
        break;
      case "text": {
        print("test TEXT");
        nodeText = ARKitNode(
          geometry: ARKitText(
          text: 'Flutter',
          extrusionDepth: 1,
          materials: [
            ARKitMaterial(
              diffuse: ARKitMaterialProperty(color: Colors.blue),
            )
          ],
        ),
          position: vector.Vector3(-0.3, 0.3, -1.4),
          scale: vector.Vector3(0.02, 0.02, 0.02),
        );

        this.arkitController.add(nodeText);
      }
        break;
      default: {
          print("carré");
          print("choice: $selectedObj");
          nodeCube = ARKitNode(
            geometry: ARKitBox(
              materials: [material],
              width: 0.2,
              height: 0.2,
              length: 0.2
            ),
            position: vector.Vector3(0, 0, -0.5),
          );

          this.arkitController.add(nodeCube);
        }
        break;
    }
  }


  _requestPermission() async {
    // Map<Permission, PermissionStatus> statuses = await [
    //   Permission.storage,
    // ].request();

    // final info = statuses[Permission.storage].toString();
    // print(info);
  }

  //void _saveDrawing() async {
    // RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject();
    // ui.Image image = await boundary.toImage(pixelRatio: 1);
    // final directory = (await getApplicationDocumentsDirectory()).path;
    // ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // Uint8List pngBytes = byteData.buffer.asUint8List();
    // print(pngBytes);
    // final result = await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
    // print(directory);
    // print(result.toString());
    
  void _saveDrawing({ Function success, Function fail }) {
    print("je passe");
    // RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject();
    // capturePng2List(boundary).then((uint8List) async {
    //   if (uint8List == null || uint8List.length == 0) {
    //     print("uint8List: $uint8List");
    //     if (fail != null) fail();
    //     return;
    //   }
    //   print("...ici...");
    //   //Directory tempDir = await getTemporaryDirectory();
    //   Directory directory = await getExternalStorageDirectory();
    //   //print("tempDir: $tempDir");
    //   print("directory: $directory");
    //   final myImagePath = '${directory.path}/MyImages' ;
    //   print("myImagePath: $myImagePath");
    //   //final myImgDir = await new Directory(myImagePath).create();
    //   //_saveImage(uint8List, myImgDir, screenshotImagePath, success: success, fail: fail);
    // });
 
  }

  // Future<Uint8List> capturePng2List(RenderRepaintBoundary boundary) async {
  //   print("dans capturePng2List...");
  //   ui.Image image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
  //   ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List pngBytes = byteData.buffer.asUint8List();
  //   print("pngBytes: $pngBytes");
  //   return pngBytes;
  // }

  // void _saveImage(Uint8List uint8List, Directory dir, String fileName, {Function success, Function fail}) async {
  //   print("_saveImage...");
  //   bool isDirExist = await Directory(dir.path).exists();
  //   print("isDirExist: $isDirExist");

  //   if (!isDirExist) Directory(dir.path).create();

  //   String tempPath = '${dir.path}$fileName';
  //   print("tempPath: $tempPath");
  //   File image = File(tempPath);
  //   print("image: $image");
  //   bool isExist = await image.exists();
  //   print("isExist: $isExist");

  //   if (isExist) await image.delete();

  //   File(tempPath).writeAsBytes(uint8List).then((_) {
  //     print("writeAsBytes");
  //     if (success != null) {
  //       print("success");
  //       success();
  //     }
  //   });
  // }




  @override
  void initState() {
    print('initState');
    _requestPermission();
    super.initState();
  }

  @override
  void didUpdateWidget(Draw widget) {
    print('didUpdateWidget');
    super.didUpdateWidget(widget);
  }
  

  @override
  Widget build(BuildContext context) {
    print("state build widget");
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(0.0),
        child: Container(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0.0),
              color: Colors.grey[300]
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Rive Flare Animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 12),
                      child: Text(
                        AppLocalizations.of(context).translate('drawingAR_drawing'),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal[300])
                      ),
                    ),
                    Container(
                      height: 60.0,
                      width: 60.0,
                      child: GestureDetector(
                        child: FlareActor(
                          "assets/flare/switchBtn.flr",
                          alignment: Alignment.center,
                          fit: BoxFit.contain,
                          animation: _animationState,
                        ),
                        onTap: () {
                          setState(() {
                            _counterAnimation();
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        "AR",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)
                      ),
                    ),
                  ],
                ),
                // Container for Simple Drawing
                (!detectAR) ? 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.gesture, size: 30, color: Colors.grey[900],),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.StrokeWidth)
                              showBottomList = !showBottomList;
                            selectedMode = SelectedMode.StrokeWidth;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.bubble_chart, size: 30, color: Colors.orange[700],),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.Color)
                              showBottomList = !showBottomList;
                            selectedMode = SelectedMode.Color;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.file_download, size: 30, color: Colors.blueGrey[700],),
                        onPressed: () {
                          setState(() {
                            _saveDrawing();
                            showBottomList = false;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 30, color: Colors.red[900],),
                        onPressed: () {
                          setState(() {
                            showBottomList = false;
                            points.clear();
                          });
                        }
                      ),
                    ],
                  )
                :
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.apps, size: 30, color: Colors.cyan[900],),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.Material)
                              showBottomList = !showBottomList;
                            selectedMode = SelectedMode.Material;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.category, size: 30, color: Colors.brown[900],),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.Object3D)
                              showBottomList = !showBottomList;
                            selectedMode = SelectedMode.Object3D;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.file_download),
                        onPressed: () {
                          setState(() {
                            showBottomList = false;
                            //paint.save();
                          });
                        }
                      ),
                    ],
                  ), 
                (!detectAR) ?
                  Visibility(
                    child: (selectedMode == SelectedMode.Color) ? Wrap(
                      direction: Axis.horizontal,
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: _getColorList(),
                    )
                    : Slider(
                      value: strokeWidth,
                      max: 50.0, //(selectedMode == SelectedMode.StrokeWidth) ? 50.0 : 1.0,
                      min: 0.0,
                      onChanged: (val) {
                        setState(() {
                          // print("value slider : $strokeWidth");
                          // print("value slider : ${(selectedMode == SelectedMode.StrokeWidth)}");
                          if (selectedMode == SelectedMode.StrokeWidth)
                            strokeWidth = val;
                        });
                      }),
                      visible: showBottomList,
                  )
                :
                  Visibility(
                    child: (selectedMode == SelectedMode.Object3D) ? Wrap(
                      direction: Axis.horizontal,
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: _getObject3D(),
                    ) :
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: _getMaterials(),
                    ),
                    visible: showBottomList,
                  ),
              ],
            ),
          ),
        ),
      ),

      body: RepaintBoundary(
        key: _globalKey,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[ 
            Container(
              child: ARKitSceneView(
                //showFeaturePoints: true,
                //planeDetection: ARPlaneDetection.horizontalAndVertical,
                onARKitViewCreated: (controller) {
                  print("is changed 1: $changed");
                  return _onArKitViewCreated(controller, selectedObj, selectedMaterial);
                }
              ),
            ),
            
            (!detectAR) ?
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox renderBox = context.findRenderObject();
                    points.add(DrawingPoints(
                        points: renderBox.globalToLocal(details.globalPosition),
                        paint: Paint()
                          ..strokeCap = strokeCap
                          ..isAntiAlias = true
                          ..color = selectedColor.withOpacity(opacity)
                          ..strokeWidth = strokeWidth));
                  });
                },
                onPanStart: (details) {
                  setState(() {
                    RenderBox renderBox = context.findRenderObject();
                    points.add(DrawingPoints(
                        points: renderBox.globalToLocal(details.globalPosition),
                        paint: Paint()
                          ..strokeCap = strokeCap
                          ..isAntiAlias = true
                          ..color = selectedColor.withOpacity(opacity)
                          ..strokeWidth = strokeWidth));
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    points.add(null);
                  });
                },
                child: Stack(
                  children: <Widget>[
                    ARKitSceneView(onARKitViewCreated: (controller) {
                      print("is changed 2: $changed");
                      return _onArKitViewCreated(controller, selectedObj, selectedMaterial);
                    }),
                    CustomPaint(
                      size: Size.infinite,
                      painter: DrawingPainter(
                        pointsList: points,
                      ),
                    ),
                  ],
                ),
                  
              )
            :
              GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  print("update details: $details");
                  
                });
              },
              onPanStart: (details) {
                setState(() {
                  print("start details: $details");
                  
                });
              },
              onPanEnd: (details) {
                setState(() {
                  print("end details: $details");
                });
              },
              child: ARKitSceneView(onARKitViewCreated: (controller) {
                  print("is changed 3: $changed");
                  return _onArKitViewCreated(controller, selectedObj, selectedMaterial);
                }
              ),
            ),

          ],
        ),
        
      ),
    
    );
  }

  @override
  void dispose() {
    print('dispose');
    arkitController?.dispose();
    super.dispose();
  }

}

class DrawingPainter extends CustomPainter {

  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points, pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(ui.PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

