import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMotelTypeMarkers {
  static const Map<String, Color> motelTypeColors = {
    'Hotel': Colors.blue,
    'Resort': Colors.green,
    'Inn': Colors.orange,
    'Guest House': Colors.purple,
    'Apartment': Colors.red,
    'Villa': Colors.teal,
    'Cottage': Colors.brown,
    'Hostel': Colors.pink,
  };

  static const Map<String, IconData> motelTypeIcons = {
    'Hotel': Icons.hotel,
    'Resort': Icons.pool,
    'Inn': Icons.home,
    'Guest House': Icons.business,
    'Apartment': Icons.apartment,
    'Villa': Icons.villa,
    'Cottage': Icons.cabin,
    'Hostel': Icons.bed,
  };

  static Color getMotelTypeColor(String motelType) {
    return motelTypeColors[motelType] ?? Colors.grey;
  }

  static IconData getMotelTypeIcon(String motelType) {
    return motelTypeIcons[motelType] ?? Icons.location_on;
  }

  static BitmapDescriptor createCustomMarkerIcon({
    required String motelType,
    required bool isSelected,
  }) {
    // This would need to be implemented with a custom marker creation method
    // For now, returning a default marker
    return BitmapDescriptor.defaultMarkerWithHue(
      isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
    );
  }

  static String getMotelTypeBadge(String motelType) {
    switch (motelType.toLowerCase()) {
      case 'hotel':
        return '🏨';
      case 'resort':
        return '🏖️';
      case 'inn':
        return '🏠';
      case 'guest house':
        return '🏘️';
      case 'apartment':
        return '🏢';
      case 'villa':
        return '🏡';
      case 'cottage':
        return '🏚️';
      case 'hostel':
        return '🛏️';
      default:
        return '🏨';
    }
  }

  static Color getBadgeColor(String motelType) {
    switch (motelType.toLowerCase()) {
      case 'hotel':
        return Colors.blue.shade700;
      case 'resort':
        return Colors.green.shade700;
      case 'inn':
        return Colors.orange.shade700;
      case 'guest house':
        return Colors.purple.shade700;
      case 'apartment':
        return Colors.red.shade700;
      case 'villa':
        return Colors.teal.shade700;
      case 'cottage':
        return Colors.brown.shade700;
      case 'hostel':
        return Colors.pink.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
