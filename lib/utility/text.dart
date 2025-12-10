import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';

class TextWidgets {
  //simple text widget
  static Widget simpleText({required String text, int maxLines = 3, TextOverflow overflow = TextOverflow.ellipsis, double fontSize = 13, double height = 1.4}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: textLight, fontSize: 13, height: 1.4),
      ),
    );
  }

  // Simple reusable icon + text row
  static Widget iconTextRow({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    double iconSize = 20,
    Color textColor = Colors.black,
    double textSize = 18,
    FontWeight textWeight = FontWeight.w700,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: deepTerracotta, size: iconSize),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textDark,
              fontSize: textSize,
              fontWeight: textWeight,
            ),
          ),
        ],
      ),
    );
  }

  static Widget iconTextColumn({
    required IconData icon,
    required String text,
    required int number,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warmSand,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: deepTerracotta, size: 24),
          const SizedBox(height: 4),
          Text(number.toString()),
          const SizedBox(height: 4),

          Text(
            text,
            style: const TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
