import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';

class AmenityCard extends StatelessWidget {
  final dynamic amenity; // Replace 'dynamic' with your Amenity model
  final VoidCallback onTap;
  final double width;

  const AmenityCard({
    super.key,
    required this.amenity,
    required this.onTap,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: warmSand, // replace with warmSand
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: earthGreen.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image or fallback icon
            const Icon(Icons.star_border, color: Colors.green, size: 28),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                amenity.name,
                style: const TextStyle(
                  color: Colors.black87, // replace with textDark
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
