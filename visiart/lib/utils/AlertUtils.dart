import 'package:flutter/material.dart';

Future<void> showAlert(
    BuildContext context, String title, String content, String btn1,
    [Function() f, String btn2, Function() f2]) async {

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(content),
            ],
          ),
        ),
        actions: <Widget>[
          if (btn1.isNotEmpty) ...[
            FlatButton(
              child: Text(btn1),
              onPressed: () {
                if (f == null) {
                  Navigator.of(context).pop();
                } else {
                  f.call();
                  //Navigator.of(context).pop();
                }
              },
            ),
          ],
          if (btn2 != null && btn2.isNotEmpty) ...[

            FlatButton(
              child: Text(btn2),
              onPressed: () {
                if (f2 == null) {
                  Navigator.of(context).pop();
                } else {
                  f2.call();
                  //Navigator.of(context).pop();
                }
              },
            ),
          ],
        ],
      );
    },
  );
}
