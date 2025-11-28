import 'package:bnbfrontendflutter/services/region_service.dart';
import 'package:bnbfrontendflutter/services/district_service.dart';
import 'package:bnbfrontendflutter/services/motel_type_service.dart';
import 'package:bnbfrontendflutter/services/simple_motel_service.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';
import 'package:flutter/material.dart';

class HomeDataService {
  static Future<Map<String, dynamic>> loadAllData({
    double? latitude,
    double? longitude,
    BuildContext? context,
  }) async {
    try {
      // Load all data in parallel
      final results = await Future.wait([
        RegionService.getRegions(context: context),
        DistrictService.getDistricts(context: context),
        MotelTypeService.getAccommodationTypes(context: context),
        SimpleMotelService.getFeaturedForUI(
          latitude: latitude,
          longitude: longitude,
          context: context,
        ),
        SimpleMotelService.getPopularForUI(
          page: 1,
          limit: 10,
          latitude: latitude,
          longitude: longitude,
          context: context,
        ),
      ]);

      final popularResult = results[4] as Map<String, dynamic>;

      // Check if any request was unauthorized (ApiClient handles logout)
      if (popularResult['unauthorized'] == true) {
        return {
          'success': false,
          'unauthorized': true,
          'regions': <Region>[],
          'districts': <District>[],
          'accommodationTypes': <Map<String, dynamic>>[],
          'featured': <SimpleMotel>[],
          'popular': <SimpleMotel>[],
          'popularPagination': <String, dynamic>{},
        };
      }

      // Safely get motels list
      List<SimpleMotel> popularMotels = [];
      if (popularResult['motels'] != null) {
        popularMotels = popularResult['motels'] as List<SimpleMotel>;
      }

      // Safely get pagination
      Map<String, dynamic> pagination = {};
      if (popularResult['pagination'] != null) {
        pagination = Map<String, dynamic>.from(popularResult['pagination']);
      }

      return {
        'regions': results[0] as List<Region>,
        'districts': results[1] as List<District>,
        'accommodationTypes': results[2] as List<Map<String, dynamic>>,
        'featured': results[3] as List<SimpleMotel>,
        'popular': popularMotels,
        'popularPagination': pagination,
        'success': true,
      };
    } catch (e) {
      debugPrint('Error loading home data: $e');
      return {
        'success': false,
        'error': e.toString(),
        'regions': <Region>[],
        'districts': <District>[],
        'accommodationTypes': <Map<String, dynamic>>[],
        'featured': <SimpleMotel>[],
        'popular': <SimpleMotel>[],
        'popularPagination': <String, dynamic>{},
      };
    }
  }

  static Future<Map<String, dynamic>> loadFilteredData({
    String? search,
    int? regionId,
    int? districtId,
    int? typeId,
    String sortBy = 'name',
    String sortOrder = 'asc',
    int page = 1,
    int limit = 10,
    double? latitude,
    double? longitude,
    BuildContext? context,
  }) async {
    try {
      // Convert string parameters to enum values
      MotelSortBy motelSortBy = MotelSortBy.motel_type;
      MotelSortOrder motelSortOrder = MotelSortOrder.asc;

      switch (sortBy.toLowerCase()) {
        case 'motel_type':
          motelSortBy = MotelSortBy.motel_type;
          break;
        case 'district':
          motelSortBy = MotelSortBy.district;
          break;
        default:
          motelSortBy = MotelSortBy.motel_type;
      }

      motelSortOrder = sortOrder.toLowerCase() == 'desc'
          ? MotelSortOrder.desc
          : MotelSortOrder.asc;

      // Load filtered motels
      final results = await Future.wait([
        SimpleMotelService.getMotels(
          search: search,
          regionId: regionId,
          districtId: districtId,
          motelTypeId: typeId,
          sortBy: motelSortBy,
          sortOrder: motelSortOrder,
          page: page,
          limit: limit,
          latitude: latitude,
          longitude: longitude,
          context: context,
        ),
        SimpleMotelService.getFeaturedForUI(
          latitude: latitude,
          longitude: longitude,
          context: context,
        ),
      ]);

      final filteredResult = results[0] as Map<String, dynamic>;
      List<SimpleMotel> featured = results[1] as List<SimpleMotel>;

      // Check if unauthorized (ApiClient handles logout)
      if (filteredResult['unauthorized'] == true) {
        return {
          'success': false,
          'unauthorized': true,
          'featured': <SimpleMotel>[],
          'popular': <SimpleMotel>[],
          'popularPagination': <String, dynamic>{},
          'allMotels': <SimpleMotel>[],
        };
      }

      // Safely get motels list
      List<SimpleMotel> allMotels = [];
      if (filteredResult['motels'] != null) {
        allMotels = filteredResult['motels'] as List<SimpleMotel>;
      }

      // Use filtered motels for popular section (limit to 10 for Near By)
      List<SimpleMotel> popular = allMotels.take(10).toList();

      // Safely get pagination
      Map<String, dynamic> pagination = {};
      if (filteredResult['pagination'] != null) {
        pagination = Map<String, dynamic>.from(filteredResult['pagination']);
      }

      return {
        'featured': featured,
        'popular': popular,
        'popularPagination': pagination,
        'allMotels': allMotels,
        'success': true,
      };
    } catch (e) {
      debugPrint('Error loading filtered data: $e');
      return {
        'success': false,
        'error': e.toString(),
        'featured': <SimpleMotel>[],
        'popular': <SimpleMotel>[],
        'popularPagination': <String, dynamic>{},
        'allMotels': <SimpleMotel>[],
      };
    }
  }

  static List<Map<String, dynamic>> sortAccommodations(
    List<Map<String, dynamic>> accommodations, {
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) {
    List<Map<String, dynamic>> sorted = List.from(accommodations);

    sorted.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortBy.toLowerCase()) {
        case 'price':
          aValue = a['price'] ?? 0;
          bValue = b['price'] ?? 0;
          break;
        case 'rating':
          aValue = a['rating'] ?? 0;
          bValue = b['rating'] ?? 0;
          break;
        case 'name':
        default:
          aValue = a['name'] ?? '';
          bValue = b['name'] ?? '';
          break;
      }

      int comparison = 0;
      if (aValue is String && bValue is String) {
        comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      }

      return sortOrder.toLowerCase() == 'desc' ? -comparison : comparison;
    });

    return sorted;
  }

  static List<String> getRegionNames(List<Region> regions) {
    return regions.map((region) => region.name).toList();
  }

  static int getRegionIdByName(List<Region> regions, String name) {
    try {
      return regions.firstWhere((region) => region.name == name).id;
    } catch (e) {
      return 0; // Return 0 for "All Regions"
    }
  }

  static int getTypeIdByName(List<Map<String, dynamic>> types, String name) {
    try {
      return types.firstWhere((type) => type['name'] == name)['id'] as int;
    } catch (e) {
      return 0; // Return 0 for "All Types"
    }
  }
}
