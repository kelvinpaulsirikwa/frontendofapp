import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'bnbconnection.dart';

enum MotelSortBy { name, motel_type, district }

enum MotelSortOrder { asc, desc }

class SimpleMotelService {
  static Future<List<SimpleMotel>> getMotels({
    String? search,
    int? regionId,
    int? districtId,
    int? motelTypeId,
    MotelSortBy sortBy = MotelSortBy.name,
    MotelSortOrder sortOrder = MotelSortOrder.asc,
  }) async {
    try {
      String url = '$baseUrl/motels';
      List<String> queryParams = [];

      if (search != null && search.isNotEmpty) {
        queryParams.add('search=$search');
      }
      if (regionId != null && regionId > 0) {
        queryParams.add('region_id=$regionId');
      }
      if (districtId != null && districtId > 0) {
        queryParams.add('district_id=$districtId');
      }
      if (motelTypeId != null && motelTypeId > 0) {
        queryParams.add('motel_type_id=$motelTypeId');
      }

      // Add sorting parameters
      String sortByString = sortBy.name;
      String sortOrderString = sortOrder.name;
      queryParams.add('sort_by=$sortByString');
      queryParams.add('sort_order=$sortOrderString');

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      print('Fetching motels from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Motels API Response Status: ${response.statusCode}');
      print('Motels API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> motelsJson = data['data'];
          List<SimpleMotel> motels = motelsJson
              .map((motelJson) => SimpleMotel.fromJson(motelJson))
              .toList();

          return motels;
        } else {
          throw Exception('Failed to parse motels data');
        }
      } else {
        throw Exception('Failed to fetch motels: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching motels: $e');
      // Return empty list if API fails
      return [];
    }
  }

  static Future<List<SimpleMotel>> getFeaturedMotels() async {
    try {
      String url = '$baseUrl/motels/featured';

      print('Fetching featured motels from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Featured Motels API Response Status: ${response.statusCode}');
      print('Featured Motels API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> motelsJson = data['data'];
          List<SimpleMotel> motels = motelsJson
              .map((motelJson) => SimpleMotel.fromJson(motelJson))
              .toList();

          return motels;
        } else {
          throw Exception('Failed to parse featured motels data');
        }
      } else {
        throw Exception(
          'Failed to fetch featured motels: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching featured motels: $e');
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

  static Future<List<SimpleMotel>> getFeaturedForUI() async {
    try {
      List<SimpleMotel> featuredMotels = await getFeaturedMotels();
      return featuredMotels;
    } catch (e) {
      print('Error getting featured motels for UI: $e');
      // Return default featured data if API fails
      return [
        SimpleMotel(
          id: 1,
          name: 'Bahari Beach Lodge',
          frontImage: null,
          streetAddress: 'Beach Road',
          motelType: 'Beach Resort',
          district: 'Zanzibar',
          longitude: 39.123456,
          latitude: -6.123456,
        ),
        SimpleMotel(
          id: 2,
          name: 'Kilimanjaro View Hotel',
          frontImage: null,
          streetAddress: 'Mountain View',
          motelType: 'Mountain Lodge',
          district: 'Kilimanjaro',
          longitude: 37.123456,
          latitude: -3.123456,
        ),
      ];
    }
  }

  static Future<List<SimpleMotel>> getPopularForUI() async {
    try {
      List<SimpleMotel> popularMotels = await getMotels(
        sortBy: MotelSortBy.name,
        sortOrder: MotelSortOrder.asc,
      );
      return popularMotels.take(5).toList();
    } catch (e) {
      print('Error getting popular motels for UI: $e');
      // Return default popular data if API fails
      return [
        SimpleMotel(
          id: 3,
          name: 'Serengeti Safari Camp',
          frontImage: null,
          streetAddress: 'National Park Road',
          motelType: 'Lodge',
          district: 'Serengeti',
          longitude: 34.123456,
          latitude: -2.123456,
        ),
        SimpleMotel(
          id: 4,
          name: 'Stone Town Heritage',
          frontImage: null,
          streetAddress: 'Stone Town Street',
          motelType: 'Hotel',
          district: 'Zanzibar',
          longitude: 39.123456,
          latitude: -6.123456,
        ),
        SimpleMotel(
          id: 5,
          name: 'Mikumi Bush Camp',
          frontImage: null,
          streetAddress: 'Park Entrance',
          motelType: 'Camp',
          district: 'Mikumi',
          longitude: 36.123456,
          latitude: -7.123456,
        ),
      ];
    }
  }
}
