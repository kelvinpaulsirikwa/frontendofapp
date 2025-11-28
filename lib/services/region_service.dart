import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

class Region {
  final int id;
  final String name;
  final int countryId;
  final String? countryName;
  final String? createdBy;

  Region({
    required this.id,
    required this.name,
    required this.countryId,
    this.countryName,
    this.createdBy,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      countryId: json['countryid'] ?? 0,
      countryName: json['country']?['name'],
      createdBy: json['createdby'],
    );
  }
}

class RegionService {
  static Future<List<Region>> getRegions({
    String? search,
    int? countryId,
    BuildContext? context,
  }) async {
    debugPrint('Fetching regions');

    Map<String, String> queryParams = {};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (countryId != null) {
      queryParams['country_id'] = countryId.toString();
    }

    final response = await ApiClient.get(
      '/regions',
      context: context,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    debugPrint('Regions Response: $response');

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> regionsJson = response['data'];
      List<Region> regions = regionsJson
          .map((regionJson) => Region.fromJson(regionJson))
          .toList();

      // Add "All Regions" option at the beginning
      regions.insert(0, Region(id: 0, name: 'All Regions', countryId: 0));

      return regions;
    } else {
      // Return default regions if API fails
      return [
        Region(id: 0, name: 'All Regions', countryId: 0),
        Region(id: 1, name: 'Dar es Salaam', countryId: 1),
        Region(id: 2, name: 'Zanzibar', countryId: 1),
        Region(id: 3, name: 'Arusha', countryId: 1),
        Region(id: 4, name: 'Serengeti', countryId: 1),
        Region(id: 5, name: 'Mwanza', countryId: 1),
        Region(id: 6, name: 'Dodoma', countryId: 1),
        Region(id: 7, name: 'Mbeya', countryId: 1),
        Region(id: 8, name: 'Tanga', countryId: 1),
      ];
    }
  }
}
