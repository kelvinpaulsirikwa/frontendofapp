import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:bnbfrontendflutter/models/bnbroommodel.dart';
import 'package:flutter/material.dart';

class RoomService {
  static Future<List<Room>> getMotelRooms(
    int motelId, {
    int page = 1,
    int limit = 10,
    String? status,
    String? roomType,
    BuildContext? context,
  }) async {
    debugPrint('Fetching rooms for motel: $motelId');

    Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty && status != 'All') {
      queryParams['status'] = status;
    }
    if (roomType != null && roomType.isNotEmpty && roomType != 'All') {
      queryParams['room_type'] = roomType;
    }

    final response = await ApiClient.get(
      '/motels/$motelId/rooms',
      context: context,
      queryParams: queryParams,
    );

    debugPrint('Rooms Response: $response');

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> roomsJson = response['data'];
      return roomsJson.map((roomJson) => Room.fromJson(roomJson)).toList();
    } else {
      return [];
    }
  }

  static Future<List<String>> getMotelRoomTypes(
    int motelId, {
    BuildContext? context,
  }) async {
    debugPrint('Fetching room types for motel: $motelId');

    final response = await ApiClient.get(
      '/motels/$motelId/room-types',
      context: context,
    );

    debugPrint('Room Types Response: $response');

    if (response['success'] == true && response['data'] != null) {
      List<dynamic> roomTypesJson = response['data'];
      return roomTypesJson
          .map((roomType) => roomType['name'] as String)
          .toList();
    } else {
      return [];
    }
  }
}
