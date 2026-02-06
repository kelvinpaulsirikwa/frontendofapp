import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

class AboutService {
  /// Fetch BnB statistics and information
  static Future<Map<String, dynamic>> getBnBStatistics({
    BuildContext? context,
  }) async {
    final response = await ApiClient.get(
      '/about/statistics',
      context: context,
    );

    return response;
  }

  /// Fetch detailed amenities list
  static Future<Map<String, dynamic>> getAmenities({
    BuildContext? context,
  }) async {
    final response = await ApiClient.get(
      '/about/amenities',
      context: context,
    );

    return response;
  }
}
