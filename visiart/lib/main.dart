import 'package:flutter/material.dart';
import 'splashscreen.dart';

//List<CameraDescription> cameras;
//Future<Null> main() async {
void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        debugShowCheckedModeBanner: false,
        home: new SplashScreen(),
    );
  }
}