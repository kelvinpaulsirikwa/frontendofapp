import 'package:flutter/material.dart';

class ErrorContent extends StatelessWidget {
  final String message;
  final Color color;
  final VoidCallback onRetry;

  const ErrorContent({
    super.key,
    required this.message,
    required this.color,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.blue,
            onPressed: onRetry,
            iconSize: 50,
          ),
        ],
      ),
    );
  }
}
