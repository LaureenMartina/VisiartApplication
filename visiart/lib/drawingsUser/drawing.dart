import 'dart:io';
import 'dart:ui';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

enum SelectedMode { StrokeWidth, Opacity, Color, Object3D, Material }

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  ARKitController arkitController;

  String _animationState = "simple";

  bool detectAR = false;
  bool changed = false;
  bool modernObj = false;
  bool showBottomList = false;

  ARKitNode nodeSphere;
  ARKitNode nodeCube;
  ARKitNode nodeCone;

  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  Color color = Colors.yellow;

  double strokeWidth = 5.0;
  double opacity = 1.0;
  
  String selectedText = "carré"; 
  IconData selectedObj = Icons.crop_square;
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

  List<IconData> obj3DBasic = [
    Icons.radio_button_unchecked,
    Icons.crop_square,
    Icons.change_history,
    Icons.ac_unit
  ];

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

    for(var obj in obj3DBasic) {
      listWidget.add(object3DDisplay(obj));
    }

    return listWidget;
  }

  Widget object3DDisplay(IconData obj) {
    return GestureDetector(
      onTap: () {
        setState(() {
          print("changed: $changed");
          changed = true;
          print("object cliqué: $selectedObj");
          //changed = true;
          selectedObj = obj;
        });
      },
      child: Container(
        child: Icon(obj, size: 30),
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

  _onArKitViewCreated(ARKitController controller, IconData obj, String decor) {
    this.arkitController = controller;
    
    ARKitMaterial material = ARKitMaterial(
      diffuse: ARKitMaterialProperty(image: decor),
    );
    
    print("choice: $obj");
    print("decor: $decor");

    switch (obj.toString()) {
      case "IconData(U+0E836)": { //IconData(U+0E86B)
          print("sphere"); 
          nodeSphere = ARKitNode(
            geometry: ARKitSphere(
              materials: [material],
              radius: 0.1
            ),
            position: vector.Vector3(0, 0, -0.5),
          );

          //this.arkitController.remove(nodeCube.name);
          this.arkitController.add(nodeSphere);
        }
        break;
      case "IconData(U+0E86B)": {
          print("cone");
          nodeCone = ARKitNode(
            geometry: ARKitCone(
                topRadius: 0,
                bottomRadius: 0.05,
                height: 0.09),
            position: vector.Vector3(0, -0.1, -0.5),
          );

          this.arkitController.add(nodeCone);
        }
        break;
      case "IconData(U+0EB3B)": {
        print("test plan");
        //this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
      }
        break;
      default: {
          print("carré"); //IconData(U+0E3C6)
          print("choice: $selectedObj");
          nodeCube = ARKitNode(
            geometry: ARKitBox(
              width: 0.1 ,
              height: 0.1,
              length: 0.1
            ),
            position: vector.Vector3(0, 0, -0.5),
          );

          this.arkitController.add(nodeCube);
        }
        break;
    }
  }


  @override
  void initState() {
    print('initState');
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
                        "Dessin", // TODO translate
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
                        icon: Icon(Icons.gesture),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.StrokeWidth)
                              showBottomList = !showBottomList;
                            selectedMode = SelectedMode.StrokeWidth;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.bubble_chart),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.Color)
                              showBottomList = !showBottomList;
                            selectedMode = SelectedMode.Color;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.file_download),
                        onPressed: () {
                          setState(() {
                            showBottomList = false;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
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
                        icon: Icon(Icons.apps),
                        onPressed: () {
                          setState(() {
                            if (selectedMode == SelectedMode.Material)
                              showBottomList = !showBottomList;
                              //print("là");
                            selectedMode = SelectedMode.Material;
                          });
                        }
                      ),
                      IconButton(
                        icon: Icon(Icons.category),
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
                          print("value slider : $strokeWidth");
                          print("value slider : ${(selectedMode == SelectedMode.StrokeWidth)}");
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

      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          //if(changed)
            // Container(
            //   child: ARKitSceneView(onARKitViewCreated: (controller) {
            //       return _onArKitViewCreated(controller, "");
            //     }
            //   ),
            // ),
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
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
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

