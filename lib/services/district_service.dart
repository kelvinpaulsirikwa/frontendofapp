import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

class District {
  final int id;
  final String name;
  final int regionId;
  final String? regionName;
  final String? createdBy;

  District({
    required this.id,
    required this.name,
    required this.regionId,
    this.regionName,
    this.createdBy,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      regionId: json['regionid'] ?? 0,
      regionName: json['region']?['name'],
      createdBy: json['createdby'],
    );
  }
}

class DistrictService {
  static Future<List<District>> getDistricts({
    String? search,
    int? regionId,
    BuildContext? context,
  }) async {
    debugPrint('Fetching districts');

    Map<String, String> queryParams = {};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (regionId != null) {
      queryParams['region_id'] = regionId.toString();
    }

    final response = await ApiClient.get(
      '/districts',
      context: context,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    debugPrint('Districts Response: $response');

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> districtsJson = response['data'];
      List<District> districts = districtsJson
          .map((districtJson) => District.fromJson(districtJson))
          .toList();

      return districts;
    } else {
      // Return empty list if API fails
      return [];
    }
  }
}
