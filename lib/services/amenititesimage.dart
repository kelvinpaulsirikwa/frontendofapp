import 'dart:convert';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AmenitiesAllImages {
  final String filepath;
  final String updatedat;
  final String? description;

  AmenitiesAllImages({
    required this.filepath,
    required this.updatedat,
    this.description,
  });

  factory AmenitiesAllImages.fromJson(Map<String, dynamic> json) {
    return AmenitiesAllImages(
      filepath: json['filepath'] ?? '',
      updatedat: json['updated_at'] ?? '',
      description: json['full_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filepath': filepath,
      'updated_at': updatedat,
      'full_image_url': description,
    };
  }

  AmenitiesAllImages copyWith({
    int? id,
    int? bnbMotelsId,
    String? filepath,
    String? updatedat,
    String? description,
    int? postedBy,
  }) {
    return AmenitiesAllImages(
      filepath: filepath ?? this.filepath,
      updatedat: updatedat ?? this.updatedat,
      description: description ?? this.description,
    );
  }
}

class AmenitiesImagesService {
  static Future<Map<String, dynamic>> getamenitiesimage(
    int bnbamenitiesid, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url =
          '$baseUrl/amenities/$bnbamenitiesid/amenitiesimage?page=$page&limit=$limit';

      debugPrint('Fetching motel images: $url');

      // Get the authentication token

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Motel Images API Response Status: ${response.statusCode}');
      debugPrint('Motel Images API Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch images',
        };
      }
    } catch (e) {
      debugPrint('Error fetching motel images: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
