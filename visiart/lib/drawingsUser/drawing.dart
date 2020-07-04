import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:visiart/config/config.dart';

enum SelectedMode { StrokeWidth, Opacity, Color, Object3D, Material }

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {

  GlobalKey _globalKey = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget _imgHolder;
  
  ARKitController arkitController;

  String _animationState = "simple";

  bool _detectAR = false;
  bool _changed = false;
  //bool _modernObj = false;
  bool _showBottomList = false;
  bool _loading = false;

  int _counterDrawing;

  ARKitNode nodeSphere, nodeCube, nodeCone, nodeCylinder, nodePyramid, nodeTorus, nodeText;

  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  Color color = Colors.yellow;

  double strokeWidth = 5.0;
  double opacity = 1.0;
  
  String _selectedObj = "cube";
  String _selectedMaterial = "";

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
         _detectAR = true;
         print("_detectAR $_detectAR");
      }else{
        _animationState = "simple";
        _detectAR = false;
        print("_detectAR $_detectAR");
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
          print("_changed: $_changed");
          _changed = true;
          _selectedObj = nameObj;
          print("object cliqué: $_selectedObj");
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
          _selectedMaterial = path;
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
    
    //print("choice: $obj");
    //print("decor: $decor");

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
          print("choice: $_selectedObj");
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


  @override
  void didUpdateWidget(Draw widget) {
    super.didUpdateWidget(widget);
  }
  

  void _createDrawing(String urlImage, int userId) async {
    var token = await SharedPref().read("token");

    Map data = {
      'urlImage': urlImage,
      'user': {
        "id": userId
      }
    };

    Response response = await post(
      API_DRAWINGS,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      print("API_REGISTER ==> 200");
      //print(response.toString());
    } else if (response.statusCode == 400) {
      String errorMsg = jsonResponse['message'][0]['messages'][0]['message'];
      print("errormsg: " + errorMsg);
      throw Exception(errorMsg);
    } else {
      throw Exception('Failed to create drawing from API');
    }
  }


  void _convertAndSaveDrawing(File fileTosave) async {
    setState(() {
      _loading = true;
    });

    int userId = await SharedPref().readInteger("userId");

    String fileName = "IMG_" + userId.toString() + "/img_${DateTime.now()}.png";
    StorageReference storageReference = FirebaseStorage().ref().child(fileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(fileTosave);
    
    await storageUploadTask.onComplete;
    
    setState(() {
      _loading = false;
    });
    
    final ref = FirebaseStorage.instance.ref().child(fileName);
    var url = await ref.getDownloadURL();
    //print("url: $url");
    _createDrawing(url, userId);
  }

  @override
  Widget build(BuildContext context) {
    //print("state build widget");
    return Scaffold(
      key: _scaffoldKey,
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
                (!_detectAR) ? 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.gesture, size: 30, color: Colors.grey[900],),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.StrokeWidth)
                              _showBottomList = !_showBottomList;
                            selectedMode = SelectedMode.StrokeWidth;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.bubble_chart, size: 30, color: Colors.orange[700],),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.Color)
                              _showBottomList = !_showBottomList;
                            selectedMode = SelectedMode.Color;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.file_download, size: 30, color: Colors.blueGrey[700],),
                        onPressed: () {
                          setState(() async {
                            String path = await NativeScreenshot.takeScreenshot();
                            debugPrint('Screenshot taken, path: $path');

                            if( path == null || path.isEmpty ) {
                              _scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).translate("myDrawings_infoErrorSave")),
                                  backgroundColor: Colors.red,
                                )
                              );
                              return;
                            }

                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context).translate("myDrawings_infoSave"))
                              )
                            ); // showSnackBar()

                            File imgFile = File(path);
                            //print("imgFile: $imgFile");
                            //_imgHolder = Image.file(imgFile);

                            setState(() {});
                            _convertAndSaveDrawing(imgFile);
                            _showBottomList = false;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 30, color: Colors.red[900],),
                        onPressed: () {
                          setState(() {
                            _showBottomList = false;
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
                              _showBottomList = !_showBottomList;
                            selectedMode = SelectedMode.Material;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.category, size: 30, color: Colors.brown[900],),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.Object3D)
                              _showBottomList = !_showBottomList;
                            selectedMode = SelectedMode.Object3D;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.file_download),
                        onPressed: () {
                          setState(() {
                            _showBottomList = false;
                            //paint.save();
                          });
                        }
                      ),
                    ],
                  ), 
                (!_detectAR) ?
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
                      visible: _showBottomList,
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
                    visible: _showBottomList,
                  ),
              ],
            ),
          ),
        ),
      ),

      body: RepaintBoundary(
        key: _globalKey,
        child:
         Stack(
          alignment: Alignment.center,
          children: <Widget>[ 
            Container(
              child: ARKitSceneView(
                //showFeaturePoints: true,
                //planeDetection: ARPlaneDetection.horizontalAndVertical,
                onARKitViewCreated: (controller) {
                  //print("is _changed 1: $_changed");
                  return _onArKitViewCreated(controller, _selectedObj, _selectedMaterial);
                }
              ),
            ),
            
            (!_detectAR) ?
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
                      //print("is _changed 2: $_changed");
                      return _onArKitViewCreated(controller, _selectedObj, _selectedMaterial);
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
                  //print("is _changed 3: $_changed");
                  return _onArKitViewCreated(controller, _selectedObj, _selectedMaterial);
                }
              ),
            ),

            (_loading) ? Center(child: CircularProgressIndicator(),) : Center(),
            Container(
              constraints: BoxConstraints.expand(),
              child: _imgHolder,
            ),
          ],
        ),
        
      ),
    );
  }

  @override
  void dispose() {
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

