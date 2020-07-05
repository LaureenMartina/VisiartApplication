import 'package:flutter/material.dart';

Future<void> showAlert(
    BuildContext context, String title, String content, String btn1,
    [Function() f]) async {

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
          FlatButton(
            child: Text(btn1),
            onPressed: () {
              if (f == null) {
                Navigator.of(context).pop();
              } else {
                f.call();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
