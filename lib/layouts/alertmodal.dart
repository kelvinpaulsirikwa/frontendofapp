import 'package:flutter/material.dart';

/// Reusable modal dialogs. Add more static methods as needed.
class AlertModal {
  AlertModal._();

  /// Shows a confirmation dialog. Returns true if user confirms, false if cancels.
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
