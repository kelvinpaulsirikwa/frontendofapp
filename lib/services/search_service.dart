import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bnbconnection.dart';

class SearchService {
  static Future<List<dynamic>> getRegions() async {
    try {
      String url = '$baseUrl/search/regions';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Search Regions API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        } else {
          throw Exception('Failed to parse regions data');
        }
      } else {
        throw Exception('Failed to fetch regions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching regions: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getAmenities() async {
    try {
      String url = '$baseUrl/search/amenities';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Search Amenities API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        } else {
          throw Exception('Failed to parse amenities data');
        }
      } else {
        throw Exception('Failed to fetch amenities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching amenities: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> searchMotels({
    String? search,
    List<String>? regions,
    List<String>? amenities,
    String sortBy = 'all',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url = '$baseUrl/search/motels';

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort_by': sortBy,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (regions != null && regions.isNotEmpty) {
        queryParams['regions'] = regions.join(',');
      }

      if (amenities != null && amenities.isNotEmpty) {
        queryParams['amenities'] = amenities.join(',');
      }

      // Build URL with query parameters
      String queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      if (queryString.isNotEmpty) {
        url += '?$queryString';
      }

      print('Searching motels from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Search Motels API Response Status: ${response.statusCode}');
      print('Search Motels API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Construct full image URLs for each motel
          final List<dynamic> motels = data['data'];
          for (var motel in motels) {
            if (motel['front_image'] != null &&
                motel['front_image'].isNotEmpty) {
              motel['front_image'] = '$baseUrl/storage/${motel['front_image']}';
            }
            // Also construct owner profile image URL if exists
            if (motel['owner'] != null &&
                motel['owner']['profileimage'] != null &&
                motel['owner']['profileimage'].isNotEmpty) {
              motel['owner']['profileimage'] =
                  '$baseUrl/storage/${motel['owner']['profileimage']}';
            }
          }
          return data;
        } else {
          throw Exception('Failed to parse search results');
        }
      } else {
        throw Exception('Failed to search motels: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching motels: $e');
      return {
        'success': false,
        'data': [],
        'pagination': {},
        'message': 'Failed to search motels',
      };
    }
  }

  static Future<List<dynamic>> getMotelImages(
    int motelId, {
    int page = 1,
    int limit = 5,
  }) async {
    try {
      String url =
          '$baseUrl/search/motels/$motelId/images?page=$page&limit=$limit';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Motel Images API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        } else {
          throw Exception('Failed to parse motel images data');
        }
      } else {
        throw Exception('Failed to fetch motel images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching motel images: $e');
      return [];
    }
  }

  static Future<bool> trackSearch(List<int> motelIds) async {
    try {
      String url = '$baseUrl/search/track';

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'motel_ids': motelIds}),
          )
          .timeout(Duration(seconds: 30));

      print('Track Search API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('Failed to track search: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error tracking search: $e');
      return false;
    }
  }
}
