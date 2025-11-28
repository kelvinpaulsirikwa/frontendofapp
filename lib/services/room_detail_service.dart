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
    debugPrint('Fetching room images for: $roomId');

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/rooms/$roomId/images',
      context: context,
      queryParams: queryParams,
    );

    debugPrint('Room Images Response: $response');

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

  static Future<List<RoomItemModel>> getRoomItems(
    int roomId, {
    int page = 1,
    int limit = 10,
    BuildContext? context,
  }) async {
    debugPrint('Fetching room items for: $roomId');

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      '/rooms/$roomId/items',
      context: context,
      queryParams: queryParams,
    );

    debugPrint('Room Items Response: $response');

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
