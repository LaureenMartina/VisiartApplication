import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class RuntimeMaterials extends StatefulWidget {
  @override
  _RuntimeMaterialsState createState() => _RuntimeMaterialsState();
}

class _RuntimeMaterialsState extends State<RuntimeMaterials> {
  ArCoreController arCoreController;
  ArCoreNode sphereNode;

  Color color = Colors.yellow;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Column(
        children: <Widget>[
          Text("Change color"),
          Expanded(
            child: ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    _addSphere(arCoreController);
  }

  void _addSphere(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Colors.yellow,
    );
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1,
    );
    sphereNode = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0, 0, -1.5),
    );
    controller.addArCoreNode(sphereNode);
  }

  onColorChange(Color newColor) {
    if (newColor != this.color) {
      this.color = newColor;
      updateMaterials();
    }
  }

  updateMaterials() {
    debugPrint("updateMaterials");
    if (sphereNode == null) {
      return;
    }
    debugPrint("updateMaterials sphere node not null");
    final material = ArCoreMaterial(
      color: color
    );
    sphereNode.shape.materials.value = [material];
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}

// class ObjectARControl extends StatefulWidget {

//   final Color initialColor;
//   final ValueChanged<Color> onColorChange;

//   const ObjectARControl({Key key, this.initialColor, this.onColorChange}) : super(key: key);

//   @override
//   _ObjectARControlState createState() => _ObjectARControlState();
// }

// class _ObjectARControlState extends State<ObjectARControl> {
//   Color color;

//   @override
//   void initState() {
//     color = widget.initialColor;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Row(
//             children: <Widget>[
//               RaisedButton(
//                 child: Text("Random Color"),
//                 onPressed: () {
//                   final newColor = Colors.accents[Random().nextInt(14)];
//                   widget.onColorChange(newColor);
//                   setState(() {
//                     color = newColor;
//                   });
//                 },
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 20.0),
//                 child: CircleAvatar(
//                   radius: 20.0,
//                   backgroundColor: color,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }