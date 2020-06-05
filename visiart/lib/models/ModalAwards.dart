import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ModalAwards  {
  String title;
  String description;
  String button;
  BuildContext context;
  String navigateTo;

  ModalAwards(this.title, this.description, this.button, this.context, this.navigateTo);

  Future<dynamic> getModal() {
    return showDialog(context: this.context, builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: Text(
          this.title,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
              ),
              child: Lottie.asset(
                "assets/lottie/winner.json",
                  width: 260,
                  height: 300,
                  fit: BoxFit.contain,
              ),
            ),
            Text(
              this.description,
              textAlign: TextAlign.center,
              style: TextStyle(),
            ),
            SizedBox(height: 10,),
            SizedBox(
              width: 320.0,
              child: RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, this.navigateTo);
                },
                child: Text(
                  this.button,
                  style: TextStyle(color: Colors.white),
                ),
                color: Color(0xFF1BC0C5),
              ),
            )
          ],
        ),
      );
    });
  }


}
