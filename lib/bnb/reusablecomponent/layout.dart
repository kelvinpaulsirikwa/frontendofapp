import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsets padding;
  final VoidCallback? onTap; // 👈 Added onTap

  const IconContainer({
    super.key,
    required this.icon,
    this.iconColor = Colors.white,
    this.iconSize = 24,
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 0.15),
    this.borderRadius = 14,
    this.borderColor = const Color.fromRGBO(255, 255, 255, 0.2),
    this.padding = const EdgeInsets.all(12),
    this.onTap, // 👈 Added parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 👈 Detects tap gesture
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}

class SmallContainer extends StatelessWidget {
  final String whatToShow;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? backgroundColor; // <-- new field for custom background color

  const SmallContainer({
    super.key,
    required this.whatToShow,
    this.onTap,
    this.showArrow = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? earthGreen, // use custom color if provided
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              whatToShow,
              style: const TextStyle(
                color: softCream,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, color: softCream, size: 12),
            ],
          ],
        ),
      ),
    );
  }
}
