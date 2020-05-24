import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class SwitchDrawing extends StatefulWidget {

  @override
  _SwitchDrawingState createState() => _SwitchDrawingState();
}

class _SwitchDrawingState extends State<SwitchDrawing> {
  String _animationState = "simple";

  void _counterAnimation() {
    setState(() {
      if(_animationState == "simple") {
         _animationState = "ar";
      }else{
        _animationState = "simple";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      width: 80.0,
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
    );
  }
}