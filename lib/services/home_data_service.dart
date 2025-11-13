import 'package:bnbfrontendflutter/services/region_service.dart';
import 'package:bnbfrontendflutter/services/district_service.dart';
import 'package:bnbfrontendflutter/services/motel_type_service.dart';
import 'package:bnbfrontendflutter/services/simple_motel_service.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';

class HomeDataService {
  static Future<Map<String, dynamic>> loadAllData() async {
    try {
      // Load all data in parallel
      final results = await Future.wait([
        RegionService.getRegions(),
        DistrictService.getDistricts(),
        MotelTypeService.getAccommodationTypes(),
        SimpleMotelService.getFeaturedForUI(),
        SimpleMotelService.getPopularForUI(),
      ]);

      return {
        'regions': results[0] as List<Region>,
        'districts': results[1] as List<District>,
        'accommodationTypes': results[2] as List<Map<String, dynamic>>,
        'featured': results[3] as List<SimpleMotel>,
        'popular': results[4] as List<SimpleMotel>,
        'success': true,
      };
    } catch (e) {
      print('Error loading home data: $e');
      return {
        'success': false,
        'error': e.toString(),
        'regions': <Region>[],
        'districts': <District>[],
        'accommodationTypes': <Map<String, dynamic>>[],
        'featured': <SimpleMotel>[],
        'popular': <SimpleMotel>[],
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
  }) async {
    try {
      // Convert string parameters to enum values
      MotelSortBy motelSortBy = MotelSortBy.name;
      MotelSortOrder motelSortOrder = MotelSortOrder.asc;

      switch (sortBy.toLowerCase()) {
        case 'motel_type':
          motelSortBy = MotelSortBy.motel_type;
          break;
        case 'district':
          motelSortBy = MotelSortBy.district;
          break;
        default:
          motelSortBy = MotelSortBy.name;
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
        ),
        SimpleMotelService.getFeaturedForUI(),
      ]);

      List<SimpleMotel> filteredMotels = results[0];
      List<SimpleMotel> featured = results[1];

      // Use filtered motels directly for popular section
      List<SimpleMotel> popular = filteredMotels.take(10).toList();

      return {
        'featured': featured,
        'popular': popular,
        'allMotels': filteredMotels,
        'success': true,
      };
    } catch (e) {
      print('Error loading filtered data: $e');
      return {
        'success': false,
        'error': e.toString(),
        'featured': <SimpleMotel>[],
        'popular': <SimpleMotel>[],
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
