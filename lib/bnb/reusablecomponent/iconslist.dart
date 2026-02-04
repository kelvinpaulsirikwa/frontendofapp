import 'package:flutter/material.dart';

/// Reusable amenity name → icon mapping. Use [getIcon] anywhere in the app.
class AmenityIcons {
  AmenityIcons._();

  static const Map<String, IconData> _icons = {
    'wifi': Icons.wifi,
    'wi-fi': Icons.wifi,
    'internet': Icons.wifi,
    'parking': Icons.local_parking,
    'pool': Icons.pool,
    'swimming': Icons.pool,
    'gym': Icons.fitness_center,
    'fitness': Icons.fitness_center,
    'restaurant': Icons.restaurant,
    'dining': Icons.restaurant,
    'bar': Icons.local_bar,
    'air conditioning': Icons.ac_unit,
    'ac': Icons.ac_unit,
    'tv': Icons.tv,
    'television': Icons.tv,
    'kitchen': Icons.kitchen,
    'laundry': Icons.local_laundry_service,
    'washing': Icons.local_laundry_service,
    'elevator': Icons.elevator,
    'lift': Icons.elevator,
    'security': Icons.security,
    'garden': Icons.yard,
    'beach': Icons.beach_access,
    'spa': Icons.spa,
    'pet': Icons.pets,
    'pets': Icons.pets,
    'breakfast': Icons.free_breakfast,
    'shuttle': Icons.airport_shuttle,
    'airport': Icons.airport_shuttle,
    'business': Icons.business_center,
    'room service': Icons.room_service,
    'concierge': Icons.support_agent,
    'hot tub': Icons.hot_tub,
    'jacuzzi': Icons.hot_tub,
    'tennis': Icons.sports_tennis,
    'bicycle': Icons.directions_bike,
    'bike': Icons.directions_bike,
    'smoking': Icons.smoking_rooms,
    'non-smoking': Icons.smoke_free,
    'reception': Icons.desk,
    'lounge': Icons.chair,
    'balcony': Icons.balcony,
    'view': Icons.visibility,
    'storage': Icons.inventory_2,
    'safe': Icons.lock,
    'minibar': Icons.liquor,
    'bathtub': Icons.bathtub,
    'shower': Icons.shower,
    'hair dryer': Icons.flash_on,
    'iron': Icons.iron,
    'workspace': Icons.desktop_windows,
    'heating': Icons.thermostat,
    'fan': Icons.ac_unit,
  };

  /// Returns the icon for an amenity name. Falls back to [Icons.star_border] if no match.
  static IconData getIcon(String amenityName) {
    final key = amenityName.trim().toLowerCase();
    if (_icons.containsKey(key)) return _icons[key]!;
    for (final e in _icons.entries) {
      if (key.contains(e.key) || e.key.contains(key)) return e.value;
    }
    return Icons.star_border;
  }
}
