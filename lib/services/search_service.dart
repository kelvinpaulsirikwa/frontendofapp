import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';
import 'package:flutter/material.dart';

class SearchService {
  static Future<List<dynamic>> getRegions({
    BuildContext? context,
  }) async {
    debugPrint('Fetching search regions');

    final response = await ApiClient.get(
      '/search/regions',
      context: context,
    );

    debugPrint('Search Regions Response: $response');

    if (response['success'] == true && response['data'] != null) {
      return response['data'];
    } else {
      return [];
    }
  }

  static Future<List<dynamic>> getAmenities({
    BuildContext? context,
  }) async {
    debugPrint('Fetching search amenities');

    final response = await ApiClient.get(
      '/search/amenities',
      context: context,
    );

    debugPrint('Search Amenities Response: $response');

    if (response['success'] == true && response['data'] != null) {
      return response['data'];
    } else {
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
    BuildContext? context,
  }) async {
    debugPrint('Searching motels');

    // Build query parameters
    Map<String, String> queryParams = {
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

    final response = await ApiClient.get(
      '/search/motels',
      context: context,
      queryParams: queryParams,
    );

    debugPrint('===== /search/motels API Response =====');
    debugPrint('$response');

    if (response['success'] == true && response['data'] != null) {
      // Construct full image URLs for each motel
      final List<dynamic> motels = response['data'];
      for (var motel in motels) {
        if (motel['front_image'] != null && motel['front_image'].isNotEmpty) {
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
      return response;
    } else {
      return {
        'success': false,
        'data': [],
        'pagination': {},
        'message': response['message'] ?? 'Failed to search motels',
      };
    }
  }

  static Future<List<dynamic>> getMotelImages(
    int motelId, {
    int page = 1,
    int limit = 5,
    BuildContext? context,
  }) async {
    debugPrint('Fetching motel images for: $motelId');

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/search/motels/$motelId/images',
      context: context,
      queryParams: queryParams,
    );

    debugPrint('Motel Images Response: $response');

    if (response['success'] == true && response['data'] != null) {
      return response['data'];
    } else {
      return [];
    }
  }

  static Future<bool> trackSearch(
    List<int> motelIds, {
    BuildContext? context,
  }) async {
    final body = {'motel_ids': motelIds};
    debugPrint('Track Search Request Body: $body');

    final response = await ApiClient.post(
      '/search/track',
      context: context,
      body: body,
    );

    debugPrint('Track Search Response: $response');

    return response['success'] == true;
  }
}
