import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bnbconnection.dart';

class NearMeService {
  static Future<Map<String, dynamic>> getNearMeMotels({
    required double latitude,
    required double longitude,
    double radius = 10.0, // Default 10km radius
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url =
          '$baseUrl/near-me/motels?latitude=$latitude&longitude=$longitude&radius=$radius&page=$page&limit=$limit';

      print('Fetching near me motels from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Near Me Motels API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Construct full image URLs for each motel
          return data;
        } else {
          throw Exception('Failed to parse near me motels data');
        }
      } else {
        throw Exception(
          'Failed to fetch near me motels: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching near me motels: $e');
      return {
        'success': false,
        'data': [],
        'pagination': {},
        'message': 'Failed to fetch near me motels',
      };
    }
  }

  static Future<Map<String, dynamic>> getTopSearchedMotels({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url = '$baseUrl/top-searched/motels?page=$page&limit=$limit';

      print('Fetching top searched motels from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Top Searched Motels API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Construct full image URLs for each motel
          return data;
        } else {
          throw Exception('Failed to parse top searched motels data');
        }
      } else {
        throw Exception(
          'Failed to fetch top searched motels: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching top searched motels: $e');
      return {
        'success': false,
        'data': [],
        'pagination': {},
        'message': 'Failed to fetch top searched motels',
      };
    }
  }

  static Future<Map<String, dynamic>> getNewestMotels({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url = '$baseUrl/newest/motels?page=$page&limit=$limit';

      print('Fetching newest motels from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Newest Motels API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Construct full image URLs for each motel
          return data;
        } else {
          throw Exception('Failed to parse newest motels data');
        }
      } else {
        throw Exception(
          'Failed to fetch newest motels: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching newest motels: $e');
      return {
        'success': false,
        'data': [],
        'pagination': {},
        'message': 'Failed to fetch newest motels',
      };
    }
  }
}
