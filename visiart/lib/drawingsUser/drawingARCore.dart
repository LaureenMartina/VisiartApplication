import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/localization/AppLocalization.dart';

enum SelectedMode { StrokeWidth, Opacity, Color, Object3D, Material }

class DrawArCore extends StatefulWidget {
  @override
  _DrawArCoreState createState() => _DrawArCoreState();
}

class _DrawArCoreState extends State<DrawArCore> {

  GlobalKey _globalKey = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget _imgHolder;

  String _animationState = "simple";

  ArCoreController arCoreController;

  bool _detectAR = false;
  bool _changed = false;
  bool _showBottomList = false;
  bool _loading = false;

  int _counterDrawing;

  ArCoreNode nodeSphere, nodeCube, nodeCylinder;

  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  Color _baseColor = Colors.yellow;

  double strokeWidth = 5.0;
  double opacity = 1.0;
  
  String _selectedObj = "cube";
  String _selectedMaterial = "assets/imgs/art.png";

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
    "cylinder": "assets/imgs/cylinder.png"
  };

  void _counterAnimation() {
    setState(() {
      if(_animationState == "simple") {
         _animationState = "ar";
         _detectAR = true;
      }else{
        _animationState = "simple";
        _detectAR = false;
      }
    });
  }

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
          if(nodeSphere != null) this.arCoreController.removeNode(nodeName: nodeSphere.name);
          if(nodeCube != null) this.arCoreController.removeNode(nodeName: nodeCube.name);
          if(nodeCylinder != null) this.arCoreController.removeNode(nodeName: nodeCylinder.name);
          nodeSphere = null;
          nodeCube = null; 
          nodeCylinder = null;
          switch(nameObj) {
            case "sphere" : {
                _addSphere();
              }
              break;
            case "cube" : {
                _addCube();
              }
              break;
            default: {
                _addCylinder();
              }
              break;
          }

          _changed = true;
          _selectedObj = nameObj;
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


  @override
  void didUpdateWidget(DrawArCore widget) {
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
      setState(() {
        _counterDrawing += 1;
        if(_counterDrawing <= COUNTER_DRAWING) {
          SharedPref().saveInteger("_counterDrawing", _counterDrawing);
        }
      });

    } else if (response.statusCode == 400) {
      String errorMsg = jsonResponse['message'][0]['messages'][0]['message'];
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

    _createDrawing(url, userId);
  }

  @override
  Widget build(BuildContext context) {
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
                            );

                            File imgFile = File(path);
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      max: 50.0,
                      min: 0.0,
                      onChanged: (val) {
                        setState(() {
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
                      children: <Widget>[
                        ListMaterialsSelection(
                          initialMaterialValue: _selectedMaterial,
                          onMaterialChange: onMaterialChange
                        ),
                      ],
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
              child: ArCoreView(
                enableTapRecognizer: true,
                onArCoreViewCreated: (controller) {
                  return _onArCoreViewCreated(controller, _selectedObj);
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
                  setState(() {});
                },
                onPanStart: (details) {
                  setState(() {});
                },
                onPanEnd: (details) {
                  setState(() {});
                },
                child: Center(),
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
    arCoreController?.dispose();
    super.dispose();
  }

  void _addSphere() async {
    final ByteData textureBytes = await rootBundle.load(_selectedMaterial);

    ArCoreMaterial material = ArCoreMaterial(
      color: _baseColor,
      textureBytes: textureBytes.buffer.asUint8List()
    );

    nodeSphere = ArCoreNode(
      shape: ArCoreSphere(
        radius: 0.2,
        materials: [material]
      ),
      position: vector.Vector3(0, 0, -1.5),
    );

    this.arCoreController.addArCoreNode(nodeSphere);
  }

  void _addCube() async {
    final ByteData textureBytes = await rootBundle.load(_selectedMaterial);

    ArCoreMaterial material = ArCoreMaterial(
      color: _baseColor,
      textureBytes: textureBytes.buffer.asUint8List()
    );

    nodeCube = ArCoreNode(
      shape: ArCoreCube(
        materials: [material],
        size: vector.Vector3(0.2, 0.2, 0.2),
      ),
      position: vector.Vector3(0, 0, -1.5),
    );

    this.arCoreController.addArCoreNode(nodeCube);
  }

  void _addCylinder() async {
    final ByteData textureBytes = await rootBundle.load(_selectedMaterial);

    ArCoreMaterial material = ArCoreMaterial(
      color: _baseColor,
      textureBytes: textureBytes.buffer.asUint8List()
    );

    nodeCylinder = ArCoreNode(
      shape: ArCoreCylinder(
        radius: 0.08,
        height: 0.15,
        materials: [material],
      ),
      position: vector.Vector3(0, 0, -1.5),
    );

    this.arCoreController.addArCoreNode(nodeCylinder);
  }

  _onArCoreViewCreated(ArCoreController controller, String obj) async {
    this.arCoreController = controller;
    if (obj == "sphere") {
      _addSphere();
    }
    else if (obj == "cube") {
      _addCube();
    }
    else if (obj == "cylinder") {
      _addCylinder();
    }
  }

  onMaterialChange(String newMaterial) {
    if (newMaterial != _selectedMaterial) {
      _selectedMaterial = newMaterial;
      updateMaterials();
    }
  }

  updateMaterials() async {
    if(nodeSphere != null) {
      this.arCoreController.removeNode(nodeName: nodeSphere.name);
      nodeSphere = null;
      _addSphere();
    } 
    if(nodeCube != null) {
      this.arCoreController.removeNode(nodeName: nodeCube.name);
      nodeCube = null;
      _addCube();
    } 
    if(nodeCylinder != null){
      this.arCoreController.removeNode(nodeName: nodeCylinder.name);
      _addCylinder();
    } 
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


class ListMaterialsSelection extends StatefulWidget {
  final String initialMaterialValue;
  final ValueChanged<String> onMaterialChange;

  ListMaterialsSelection({Key key, this.initialMaterialValue, this.onMaterialChange}): super(key: key);

  @override
  _ListMaterialsSelectionState createState() => _ListMaterialsSelectionState();
}

class _ListMaterialsSelectionState extends State<ListMaterialsSelection> {
  String materialValue;

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

  @override
  void initState() {
    materialValue = widget.initialMaterialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      child: ListView.builder(
        itemCount: materialsLink.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                widget.onMaterialChange(materialsLink[index]);
                setState(() {
                  materialValue = materialsLink[index];
                });
              });
            },
            child: ClipOval(
              child: Container(
                padding: EdgeInsets.only(bottom: 16.0, top: 20),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(materialsLink[index])
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}