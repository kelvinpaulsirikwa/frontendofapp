import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlertReturn {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter, // Align to the bottom
            child: Container(
              margin: const EdgeInsets.all(
                20,
              ), // Optional: Add margin if needed
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 30,
              ), // Optional: Add padding if needed
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(
                  0.8,
                ), // Optional: Background color with opacity
                borderRadius: BorderRadius.circular(
                  10,
                ), // Optional: Rounded corners
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text("Logging in...", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
