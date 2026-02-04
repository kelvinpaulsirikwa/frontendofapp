import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';

class AmenityCard extends StatelessWidget {
  final dynamic amenity;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  const AmenityCard({
    super.key,
    required this.amenity,
    required this.onTap,
    this.margin = const EdgeInsets.only(right: 6),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: warmSand,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: earthGreen.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          amenity.name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
