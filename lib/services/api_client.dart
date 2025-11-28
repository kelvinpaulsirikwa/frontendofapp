import 'dart:convert';
import 'package:bnbfrontendflutter/auth/loginpage.dart';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Centralized API client that handles authentication and 401 responses.
/// All API requests should use this client to ensure proper token handling.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Global navigator key for logout navigation
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Set the navigator key for handling logout navigation
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// Get authentication headers with token
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await UserPreferences.getApiToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Check if user has a valid token
  static Future<bool> hasValidToken() async {
    final token = await UserPreferences.getApiToken();
    return token != null && token.isNotEmpty;
  }

  /// Handle 401 unauthorized response - logout user
  static Future<void> handleUnauthorized(BuildContext? context) async {
    debugPrint('=== UNAUTHORIZED - Logging out user ===');
    
    // Clear all user data
    await UserPreferences.clearAll();
    
    // Navigate to login page
    if (context != null && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } else if (navigatorKey?.currentState != null) {
      navigatorKey!.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  /// Process response and handle 401 errors
  static Future<Map<String, dynamic>> processResponse(
    http.Response response, {
    BuildContext? context,
  }) async {
    debugPrint('API Response Status: ${response.statusCode}');
    
    // Handle 401 Unauthorized
    if (response.statusCode == 401) {
      await handleUnauthorized(context);
      return {
        'success': false,
        'message': 'Unauthorized. Please login again.',
        'unauthorized': true,
      };
    }

    // Handle other error codes
    if (response.statusCode >= 400) {
      try {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Request failed',
          'error': errorData,
          'statusCode': response.statusCode,
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Request failed with status ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    }

    // Success response
    try {
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': true,
        'data': response.body,
      };
    }
  }

  /// Make an authenticated GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    BuildContext? context,
    Map<String, String>? queryParams,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Check for token first
      if (!await hasValidToken()) {
        await handleUnauthorized(context);
        return {
          'success': false,
          'message': 'No authentication token found. Please login.',
          'unauthorized': true,
        };
      }

      final headers = await getAuthHeaders();
      
      String url = '$baseUrl$endpoint';
      if (queryParams != null && queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$queryString';
      }

      debugPrint('GET Request: $url');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout);

      return await processResponse(response, context: context);
    } catch (e) {
      debugPrint('API GET Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Make an authenticated POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    BuildContext? context,
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Check for token first
      if (!await hasValidToken()) {
        await handleUnauthorized(context);
        return {
          'success': false,
          'message': 'No authentication token found. Please login.',
          'unauthorized': true,
        };
      }

      final headers = await getAuthHeaders();
      final url = '$baseUrl$endpoint';

      debugPrint('POST Request: $url');
      debugPrint('POST Body: $body');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return await processResponse(response, context: context);
    } catch (e) {
      debugPrint('API POST Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Make an authenticated PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    BuildContext? context,
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Check for token first
      if (!await hasValidToken()) {
        await handleUnauthorized(context);
        return {
          'success': false,
          'message': 'No authentication token found. Please login.',
          'unauthorized': true,
        };
      }

      final headers = await getAuthHeaders();
      final url = '$baseUrl$endpoint';

      debugPrint('PUT Request: $url');
      debugPrint('PUT Body: $body');

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return await processResponse(response, context: context);
    } catch (e) {
      debugPrint('API PUT Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Make an authenticated DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    BuildContext? context,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // Check for token first
      if (!await hasValidToken()) {
        await handleUnauthorized(context);
        return {
          'success': false,
          'message': 'No authentication token found. Please login.',
          'unauthorized': true,
        };
      }

      final headers = await getAuthHeaders();
      final url = '$baseUrl$endpoint';

      debugPrint('DELETE Request: $url');

      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(timeout);

      return await processResponse(response, context: context);
    } catch (e) {
      debugPrint('API DELETE Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}

