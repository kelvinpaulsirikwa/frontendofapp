import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

class NearMeService {
  static Future<Map<String, dynamic>> getNearMeMotels({
    required double latitude,
    required double longitude,
    double radius = 10.0, // Default 10km radius
    int page = 1,
    int limit = 10,
    BuildContext? context,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius': radius.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/near-me/motels',
      context: context,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      return response;
    } else {
      return {
        'success': false,
        'data': [],
        'pagination': {},
        'message': response['message'] ?? 'Failed to fetch near me motels',
      };
    }
  }

  static Future<Map<String, dynamic>> getTopSearchedMotels({
    int page = 1,
    int limit = 10,
    BuildContext? context,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/top-searched/motels',
      context: context,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      return response;
    } else {
      return {
        'success': false,
        'data': [],
        'pagination': {},
        'message': response['message'] ?? 'Failed to fetch top searched motels',
      };
    }
  }

  static Future<Map<String, dynamic>> getNewestMotels({
    int page = 1,
    int limit = 10,
    BuildContext? context,
  }) async {

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/newest/motels',
      context: context,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      return response;
    } else {
      return {
        'success': false,
        'data': [],
        'pagination': {},
        'message': response['message'] ?? 'Failed to fetch newest motels',
      };
    }
  }
}
