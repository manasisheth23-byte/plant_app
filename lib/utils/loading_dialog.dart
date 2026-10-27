import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context, {String message = "Data is Syncing please wait..."}) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(
          color: Colors.blue,
          backgroundColor: Colors.white,
        ),
        Container(
          margin: EdgeInsets.only(left: 7),
          child: Text(message),
        ),
      ],
    ),
  );

  showDialog(
    barrierDismissible: false, // Prevent dialog from being dismissed
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}