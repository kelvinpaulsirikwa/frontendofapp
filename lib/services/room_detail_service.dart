import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bnbfrontendflutter/models/room_detail_model.dart';
import 'bnbconnection.dart';

class RoomDetailService {

  static Future<List<RoomImageModel>> getRoomImages(
    int roomId, {
    int page = 1,
    int limit = 5,
  }) async {
    try {
      String url = '$baseUrl/rooms/$roomId/images?page=$page&limit=$limit';

      print('Fetching room images from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Room Images API Response Status: ${response.statusCode}');
      print('Room Images API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> imagesJson = data['data'];
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
          throw Exception('Failed to parse room images data');
        }
      } else {
        throw Exception('Failed to fetch room images: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching room images: $e');
      return [];
    }
  }

  static Future<List<RoomItemModel>> getRoomItems(
    int roomId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url = '$baseUrl/rooms/$roomId/items?page=$page&limit=$limit';

      print('Fetching room items from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Room Items API Response Status: ${response.statusCode}');
      print('Room Items API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<dynamic> itemsJson = data['data'];
          return itemsJson
              .map((itemJson) => RoomItemModel.fromJson(itemJson))
              .toList();
        } else {
          throw Exception('Failed to parse room items data');
        }
      } else {
        throw Exception('Failed to fetch room items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching room items: $e');
      return [];
    }
  }
}
