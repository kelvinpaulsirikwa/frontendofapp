import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlertReturn {
  // Show error dialog if sign-in fails
  static void showerror(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void showToast(String toastmessage) {
    Fluttertoast.showToast(
      msg: toastmessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black45,
      textColor: Colors.white70,
    );
  }
}
