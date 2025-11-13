import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bnbfrontendflutter/models/bnb_motels_details_model.dart';
import 'bnbconnection.dart';

class BnbImage {
  final int id;
  final int motelId;
  final String imageUrl;
  final String? description;
  final DateTime? createdAt;

  BnbImage({
    required this.id,
    required this.motelId,
    required this.imageUrl,
    this.description,
    this.createdAt,
  });

  factory BnbImage.fromJson(Map<String, dynamic> json) {
    return BnbImage(
      id: json['id'] ?? 0,
      motelId: json['bnb_motels_id'] ?? 0,
      imageUrl: json['filepath'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class BnbAmenity {
  final int id;
  final int motelId;
  final String name;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;

  BnbAmenity({
    required this.id,
    required this.motelId,
    required this.name,
    this.description,
    this.imageUrl,
    this.createdAt,
  });

  factory BnbAmenity.fromJson(Map<String, dynamic> json) {
    return BnbAmenity(
      id: json['id'] ?? 0,
      motelId: json['bnb_motels_id'] ?? 0,
      name: json['amenity']?['name'] ?? '',
      description: json['description'],
      imageUrl: json['images']?.isNotEmpty == true
          ? json['images'][0]['filepath']
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class MotelDetail {
  final int id;
  final String name;
  final String? frontImage;
  final String streetAddress;
  final String motelType;
  final String district;
  final double? longitude;
  final double? latitude;
  final String? contactPhone;
  final String? contactEmail;
  final int? totalRooms;
  final int? availableRooms;
  final String? description;
  final String? ownerName;
  final String? ownerEmail;

  MotelDetail({
    required this.id,
    required this.name,
    this.frontImage,
    required this.streetAddress,
    required this.motelType,
    required this.district,
    this.longitude,
    this.latitude,
    this.contactPhone,
    this.contactEmail,
    this.totalRooms,
    this.availableRooms,
    this.description,
    this.ownerName,
    this.ownerEmail,
  });

  factory MotelDetail.fromJson(Map<String, dynamic> json) {
    return MotelDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Motel',
      frontImage: json['front_image'],
      streetAddress: json['street_address'] ?? 'Unknown Street',
      motelType: json['motel_type']?['name'] ?? 'Unknown Type',
      district: json['district']?['name'] ?? 'Unknown District',
      longitude: (json['longitude'] != null)
          ? double.tryParse(json['longitude'].toString())
          : null,
      latitude: (json['latitude'] != null)
          ? double.tryParse(json['latitude'].toString())
          : null,
      contactPhone: json['details']?['contact_phone'],
      contactEmail: json['details']?['contact_email'],
      totalRooms: json['details']?['total_rooms'],
      availableRooms: json['details']?['available_rooms'],
      description: json['details']?['description'],
      ownerName: json['owner']?['name'],
      ownerEmail: json['owner']?['email'],
    );
  }
}

class MotelImageModel {
  final int id;
  final int bnbMotelsId;
  final String filepath;
  final String createdAt;
  final String? fullImageUrl;
  final int? postedBy;

  MotelImageModel({
    required this.id,
    required this.bnbMotelsId,
    required this.filepath,
    required this.createdAt,
    this.fullImageUrl,
    this.postedBy,
  });

  factory MotelImageModel.fromJson(Map<String, dynamic> json) {
    return MotelImageModel(
      id: json['id'] ?? 0,
      bnbMotelsId: json['bnb_motels_id'] ?? 0,
      filepath: json['filepath'] ?? '',
      createdAt: json['created_at'] ?? '',
      fullImageUrl: json['full_image_url'],
      postedBy: json['posted_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bnb_motels_id': bnbMotelsId,
      'filepath': filepath,
      'created_at': createdAt,
      'full_image_url': fullImageUrl,
    };
  }

  MotelImageModel copyWith({
    int? id,
    int? bnbMotelsId,
    String? filepath,
    String? createdAt,
    String? fullImageUrl,
    int? postedBy,
  }) {
    return MotelImageModel(
      id: id ?? this.id,
      bnbMotelsId: bnbMotelsId ?? this.bnbMotelsId,
      filepath: filepath ?? this.filepath,
      createdAt: createdAt ?? this.createdAt,
      fullImageUrl: fullImageUrl ?? this.fullImageUrl,
      postedBy: postedBy ?? this.postedBy,
    );
  }
}

class MotelDetailService {
  static Future<BnbMotelsDetailsModel?> getMotelDetails(int motelId) async {
    try {
      String url = '$baseUrl/motels/$motelId/details';

      print('Fetching motel details from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Motel Details API Response Status: ${response.statusCode}');
      print('Motel Details API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          return BnbMotelsDetailsModel.fromJson(data['data']);
        } else {
          throw Exception('Failed to parse motel details data');
        }
      } else {
        throw Exception(
          'Failed to fetch motel details: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching motel details: $e');
      return null;
    }
  }

  static Future<List<BnbImageModel>> getMotelImages(
    int motelId, {
    int page = 1,
    int limit = 5,
  }) async {
    try {
      String url = '$baseUrl/motels/$motelId/images?page=$page&limit=$limit';

      print('Fetching motel images from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Motel Images API Response Status: ${response.statusCode}');
      print('Motel Images API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> imagesJson = data['data'];
          return imagesJson
              .map((imageJson) => BnbImageModel.fromJson(imageJson))
              .toList();
        } else {
          throw Exception('Failed to parse motel images data');
        }
      } else {
        throw Exception('Failed to fetch motel images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching motel images: $e');
      return [];
    }
  }

  /// Get all images for a specific motel
  static Future<Map<String, dynamic>> getpaginghotelimage(
    int motelId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url =
          '$baseUrl/user/motels/$motelId/images?page=$page&limit=$limit';

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

  static Future<List<BnbAmenityModel>> getMotelAmenities(
    int motelId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url = '$baseUrl/motels/$motelId/amenities?page=$page&limit=$limit';

      print('Fetching motel amenities from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Motel Amenities API Response Status: ${response.statusCode}');
      print('Motel Amenities API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> amenitiesJson = data['data'];
          return amenitiesJson
              .map((amenityJson) => BnbAmenityModel.fromJson(amenityJson))
              .toList();
        } else {
          throw Exception('Failed to parse motel amenities data');
        }
      } else {
        throw Exception(
          'Failed to fetch motel amenities: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching motel amenities: $e');
      return [];
    }
  }
}
