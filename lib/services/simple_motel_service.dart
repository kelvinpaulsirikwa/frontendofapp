import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:flutter/material.dart';

enum MotelSortBy { name, motel_type, district }

enum MotelSortOrder { asc, desc }

class SimpleMotelService {
  static Future<Map<String, dynamic>> getMotels({
    String? search,
    int? regionId,
    int? districtId,
    int? motelTypeId,
    MotelSortBy sortBy = MotelSortBy.name,
    MotelSortOrder sortOrder = MotelSortOrder.asc,
    int? page,
    int? limit,
    double? latitude,
    double? longitude,
    BuildContext? context,
  }) async {
    debugPrint('Fetching motels');

    Map<String, String> queryParams = {};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (regionId != null && regionId > 0) {
      queryParams['region_id'] = regionId.toString();
    }
    if (districtId != null && districtId > 0) {
      queryParams['district_id'] = districtId.toString();
    }
    if (motelTypeId != null && motelTypeId > 0) {
      queryParams['motel_type_id'] = motelTypeId.toString();
    }

    // Add sorting parameters
    queryParams['sort_by'] = sortBy.name;
    queryParams['sort_order'] = sortOrder.name;

    // Add pagination parameters
    if (page != null && page > 0) {
      queryParams['page'] = page.toString();
    }
    if (limit != null && limit > 0) {
      queryParams['limit'] = limit.toString();
    }

    // Add location parameters for distance-based sorting
    if (latitude != null && longitude != null) {
      queryParams['latitude'] = latitude.toString();
      queryParams['longitude'] = longitude.toString();
    }

    final response = await ApiClient.get(
      '/motels',
      context: context,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    debugPrint('Motels Response: $response');

    // Check if unauthorized - return empty result (ApiClient handles logout)
    if (response['unauthorized'] == true) {
      return {
        'motels': <SimpleMotel>[],
        'pagination': <String, dynamic>{},
        'success': false,
        'unauthorized': true,
      };
    }

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> motelsJson = response['data'];
      List<SimpleMotel> motels = motelsJson
          .map((motelJson) => SimpleMotel.fromJson(motelJson))
          .toList();

      // Safely cast pagination
      Map<String, dynamic> pagination = {};
      if (response['pagination'] != null) {
        pagination = Map<String, dynamic>.from(response['pagination']);
      }

      return {
        'motels': motels,
        'pagination': pagination,
        'success': true,
      };
    } else {
      return {
        'motels': <SimpleMotel>[],
        'pagination': <String, dynamic>{},
        'success': false,
        'error': response['message'] ?? 'Failed to fetch motels',
      };
    }
  }

  static Future<List<SimpleMotel>> getFeaturedMotels({
    double? latitude,
    double? longitude,
    BuildContext? context,
  }) async {
    debugPrint('Fetching featured motels');

    Map<String, String>? queryParams;

    // Add location parameters for distance-based sorting
    if (latitude != null && longitude != null) {
      queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };
    }

    final response = await ApiClient.get(
      '/motels/featured',
      context: context,
      queryParams: queryParams,
    );

    debugPrint('Featured Motels Response: $response');

    // Check if unauthorized - return empty result (ApiClient handles logout)
    if (response['unauthorized'] == true) {
      return [];
    }

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> motelsJson = response['data'];
      List<SimpleMotel> motels = motelsJson
          .map((motelJson) => SimpleMotel.fromJson(motelJson))
          .toList();

      return motels;
    } else {
      // Return empty list if API fails
      return [];
    }
  }

  // Convert SimpleMotel to featured format for UI
  static Map<String, dynamic> simpleMotelToFeatured(SimpleMotel motel) {
    String badge;

    switch (motel.motelType.toLowerCase()) {
      case 'hotel':
        badge = 'Luxury Stay';
        break;
      case 'lodge':
        badge = 'Safari Ready';
        break;
      case 'resort':
        badge = 'Karibu Sana';
        break;
      case 'motel':
        badge = 'Business Ready';
        break;
      case 'guest house':
        badge = 'Cozy Stay';
        break;
      case 'inn':
        badge = 'Local Experience';
        break;
      default:
        badge = 'Featured';
    }

    return {
      'name': motel.name,
      'location': '${motel.streetAddress}, ${motel.district}',
      'type': motel.motelType,
      'rating': 4.5, // Default rating since not in SimpleMotel model
      'price': 50000, // Default price since not in SimpleMotel model
      'badge': badge,
      'front_image': motel.frontImage,
      'district': motel.district,
      'street_address': motel.streetAddress,
      'longitude': motel.longitude,
      'latitude': motel.latitude,
    };
  }

  // Convert SimpleMotel to popular format for UI
  static Map<String, dynamic> simpleMotelToPopular(SimpleMotel motel) {
    String nights = 'Flexible';
    if (motel.motelType.toLowerCase() == 'lodge' ||
        motel.motelType.toLowerCase() == 'resort') {
      nights = 'Min 2 nights';
    }

    return {
      'name': motel.name,
      'location': '${motel.streetAddress}, ${motel.district}',
      'price': 50000, // Default price since not in SimpleMotel model
      'rating': 4.5, // Default rating since not in SimpleMotel model
      'nights': nights,
      'amenities': ['WiFi', 'Parking', 'Restaurant'], // Default amenities
      'type': motel.motelType,
      'front_image': motel.frontImage,
      'district': motel.district,
      'street_address': motel.streetAddress,
      'longitude': motel.longitude,
      'latitude': motel.latitude,
    };
  }

  static Future<List<SimpleMotel>> getFeaturedForUI({
    double? latitude,
    double? longitude,
    BuildContext? context,
  }) async {
    try {
      List<SimpleMotel> featuredMotels = await getFeaturedMotels(
        latitude: latitude,
        longitude: longitude,
        context: context,
      );
      // Limit to 10 items for "Near By" section
      return featuredMotels.take(10).toList();
    } catch (e) {
      debugPrint('Error getting featured motels for UI: $e');
      // Return empty list if API fails
      return [];
    }
  }

  static Future<Map<String, dynamic>> getPopularForUI({
    int page = 1,
    int limit = 10,
    double? latitude,
    double? longitude,
    String? search,
    int? regionId,
    int? districtId,
    int? motelTypeId,
    BuildContext? context,
  }) async {
    try {
      final result = await getMotels(
        search: search,
        regionId: regionId,
        districtId: districtId,
        motelTypeId: motelTypeId,
        sortBy: MotelSortBy.motel_type,
        sortOrder: MotelSortOrder.asc,
        page: page,
        limit: limit,
        latitude: latitude,
        longitude: longitude,
        context: context,
      );
      return result;
    } catch (e) {
      debugPrint('Error getting popular motels for UI: $e');
      return {
        'motels': <SimpleMotel>[],
        'pagination': <String, dynamic>{},
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
