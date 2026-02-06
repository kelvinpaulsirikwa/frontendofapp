import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

class TermsService {
  static Future<Map<String, dynamic>> getActiveTerms({
    BuildContext? context,
  }) async {
    debugPrint('Fetching terms of service');

    final response = await ApiClient.get(
      '/terms-of-service',
      context: context,
    );

    debugPrint('Terms of Service Response: $response');
    return response;
  }
}
