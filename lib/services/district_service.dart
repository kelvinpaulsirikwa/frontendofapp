import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bnbconnection.dart';

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
  }) async {
    try {
      String url = '$baseUrl/districts';
      List<String> queryParams = [];

      if (search != null && search.isNotEmpty) {
        queryParams.add('search=$search');
      }
      if (regionId != null) {
        queryParams.add('region_id=$regionId');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      print('Fetching districts from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Districts API Response Status: ${response.statusCode}');
      print('Districts API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> districtsJson = data['data'];
          List<District> districts = districtsJson
              .map((districtJson) => District.fromJson(districtJson))
              .toList();

          return districts;
        } else {
          throw Exception('Failed to parse districts data');
        }
      } else {
        throw Exception('Failed to fetch districts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching districts: $e');
      // Return empty list if API fails
      return [];
    }
  }
}
