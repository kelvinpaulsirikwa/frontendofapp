import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bnbfrontendflutter/models/bnbroommodel.dart';
import 'bnbconnection.dart';

class RoomService {
  static Future<List<Room>> getMotelRooms(
    int motelId, {
    int page = 1,
    int limit = 10,
    String? status,
    String? roomType,
  }) async {
    try {
      String url = '$baseUrl/motels/$motelId/rooms?page=$page&limit=$limit';

      List<String> queryParams = [];
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams.add('status=$status');
      }
      if (roomType != null && roomType.isNotEmpty && roomType != 'All') {
        queryParams.add('room_type=$roomType');
      }

      if (queryParams.isNotEmpty) {
        url += '&${queryParams.join('&')}';
      }

      print('Fetching rooms from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Rooms API Response Status: ${response.statusCode}');
      print('Rooms API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> roomsJson = data['data'];
          return roomsJson.map((roomJson) => Room.fromJson(roomJson)).toList();
        } else {
          throw Exception('Failed to parse rooms data');
        }
      } else {
        throw Exception('Failed to fetch rooms: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }

  static Future<List<String>> getMotelRoomTypes(int motelId) async {
    try {
      String url = '$baseUrl/motels/$motelId/room-types';

      print('Fetching motel room types from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Room Types API Response Status: ${response.statusCode}');
      print('Room Types API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> roomTypesJson = data['data'];
          return roomTypesJson
              .map((roomType) => roomType['name'] as String)
              .toList();
        } else {
          throw Exception('Failed to parse room types data');
        }
      } else {
        throw Exception('Failed to fetch room types: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching room types: $e');
      return [];
    }
  }
}
