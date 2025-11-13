import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bnbconnection.dart';

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
  }) async {
    try {
      String url = '$baseUrl/regions';
      List<String> queryParams = [];

      if (search != null && search.isNotEmpty) {
        queryParams.add('search=$search');
      }
      if (countryId != null) {
        queryParams.add('country_id=$countryId');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      print('Fetching regions from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Regions API Response Status: ${response.statusCode}');
      print('Regions API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> regionsJson = data['data'];
          List<Region> regions = regionsJson
              .map((regionJson) => Region.fromJson(regionJson))
              .toList();

          // Add "All Regions" option at the beginning
          regions.insert(0, Region(id: 0, name: 'All Regions', countryId: 0));

          return regions;
        } else {
          throw Exception('Failed to parse regions data');
        }
      } else {
        throw Exception('Failed to fetch regions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching regions: $e');
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
