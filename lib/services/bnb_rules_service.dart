import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

class BnbRule {
  final int id;
  final int motelId;
  final String? rules;
  final String? createdAt;
  final String? updatedAt;

  BnbRule({
    required this.id,
    required this.motelId,
    this.rules,
    this.createdAt,
    this.updatedAt,
  });

  factory BnbRule.fromJson(Map<String, dynamic> json) {
    return BnbRule(
      id: json['id'] ?? 0,
      motelId: json['motel_id'] ?? 0,
      rules: json['rules'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class BnbRulesService {
  /// Fetch BNB rules for a specific motel
  static Future<Map<String, dynamic>> getMotelRules(
    int motelId, {
    BuildContext? context,
  }) async {
    debugPrint('Fetching BNB rules for motel: $motelId');

    final response = await ApiClient.get(
      '/motels/$motelId/rules',
      context: context,
    );

    debugPrint('BNB Rules Response: $response');

    if (response['success'] == true && response['data'] != null) {
      return {
        'success': true,
        'data': BnbRule.fromJson(response['data']),
        'message': response['message'] ?? 'Rules retrieved successfully',
      };
    } else if (response['success'] == true && response['data'] == null) {
      // No rules found for this motel
      return {
        'success': true,
        'data': null,
        'message': response['message'] ?? 'No rules found for this motel',
      };
    } else {
      return {
        'success': false,
        'data': null,
        'message': response['message'] ?? 'Failed to retrieve rules',
      };
    }
  }
}


