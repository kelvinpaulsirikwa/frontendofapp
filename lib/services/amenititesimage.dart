import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

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
    BuildContext? context,
  }) async {
    debugPrint('Fetching amenities images for: $bnbamenitiesid');

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/amenities/$bnbamenitiesid/amenitiesimage',
      context: context,
      queryParams: queryParams,
    );

    debugPrint('Amenities Images Response: $response');
    return response;
  }
}
