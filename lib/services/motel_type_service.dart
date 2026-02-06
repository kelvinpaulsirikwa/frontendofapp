import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

class MotelType {
  final int id;
  final String name;
  final String? createdBy;

  MotelType({required this.id, required this.name, this.createdBy});

  factory MotelType.fromJson(Map<String, dynamic> json) {
    return MotelType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      createdBy: json['createby'],
    );
  }

  // Map to accommodation type format for UI
  Map<String, dynamic> toAccommodationType() {
    IconData icon;
    switch (name.toLowerCase()) {
      case 'hotel':
        icon = Icons.hotel;
        break;
      case 'lodge':
        icon = Icons.cottage_outlined;
        break;
      case 'gesti':
        icon = Icons.house_outlined;
        break;
      case 'motel':
        icon = Icons.meeting_room;
        break;
      case 'resort':
        icon = Icons.villa;
        break;
      case 'hostel':
        icon = Icons.bed;
        break;
      default:
        icon = Icons.home_outlined;
    }

    return {'name': name, 'icon': icon, 'id': id};
  }
}

class MotelTypeService {
  static Future<List<Map<String, dynamic>>> getAccommodationTypes({
    String? search,
    BuildContext? context,
  }) async {
    Map<String, String>? queryParams;
    if (search != null && search.isNotEmpty) {
      queryParams = {'search': search};
    }

    final response = await ApiClient.get(
      '/motel-types',
      context: context,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> typesJson = response['data'];
      List<MotelType> types = typesJson
          .map((typeJson) => MotelType.fromJson(typeJson))
          .toList();

      // Convert to accommodation type format
      List<Map<String, dynamic>> accommodationTypes = types
          .map((type) => type.toAccommodationType())
          .toList();

      // Add "All Types" option at the beginning
      accommodationTypes.insert(0, {
        'name': 'All Types',
        'icon': Icons.home_outlined,
        'id': 0,
      });

      return accommodationTypes;
    } else {
      // Return default accommodation types if API fails
      return [
        {'name': 'All Types', 'icon': Icons.home_outlined, 'id': 0},
        {'name': 'Hotel', 'icon': Icons.hotel, 'id': 1},
        {'name': 'Lodge', 'icon': Icons.cottage_outlined, 'id': 2},
        {'name': 'Gesti', 'icon': Icons.house_outlined, 'id': 3},
        {'name': 'Motel', 'icon': Icons.meeting_room, 'id': 4},
        {'name': 'Resort', 'icon': Icons.villa, 'id': 5},
        {'name': 'Hostel', 'icon': Icons.bed, 'id': 6},
      ];
    }
  }
}
