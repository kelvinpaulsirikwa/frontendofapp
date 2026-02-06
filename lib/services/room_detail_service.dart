import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';
import 'package:bnbfrontendflutter/models/room_detail_model.dart';
import 'package:flutter/material.dart';

class RoomDetailService {
  static Future<List<RoomImageModel>> getRoomImages(
    int roomId, {
    int page = 1,
    int limit = 5,
    BuildContext? context,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/rooms/$roomId/images',
      context: context,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> imagesJson = response['data'];
      return imagesJson.map((imageJson) {
        // Construct full image URL
        if (imageJson['imagepath'] != null &&
            imageJson['imagepath'].isNotEmpty) {
          imageJson['imagepath'] =
              '$baseUrl/storage/${imageJson['imagepath']}';
        }
        return RoomImageModel.fromJson(imageJson);
      }).toList();
    } else {
      return [];
    }
  }

  /// Paging version - returns raw API response for BnBRoomImages
  static Future<Map<String, dynamic>> getRoomImagesPaging(
    int roomId, {
    int page = 1,
    int limit = 10,
    BuildContext? context,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/rooms/$roomId/images',
      context: context,
      queryParams: queryParams,
    );

    return response;
  }

  static Future<List<RoomItemModel>> getRoomItems(
    int roomId, {
    int page = 1,
    int limit = 10,
    BuildContext? context,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/rooms/$roomId/items',
      context: context,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> itemsJson = response['data'];
      return itemsJson
          .map((itemJson) => RoomItemModel.fromJson(itemJson))
          .toList();
    } else {
      return [];
    }
  }
}
