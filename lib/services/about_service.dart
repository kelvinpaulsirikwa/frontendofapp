import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bnbconnection.dart';

class AboutService {
  /// Fetch BnB statistics and information
  static Future<Map<String, dynamic>> getBnBStatistics() async {
    try {
      String url = '$baseUrl/about/statistics';

      print('Fetching BnB statistics: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('BnB Statistics API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
          'Failed to fetch BnB statistics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching BnB statistics: $e');
      return {
        'success': false,
        'message': 'Failed to fetch BnB statistics: $e',
      };
    }
  }

  /// Fetch detailed amenities list
  static Future<Map<String, dynamic>> getAmenities() async {
    try {
      String url = '$baseUrl/about/amenities';

      print('Fetching amenities: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print('Amenities API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch amenities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching amenities: $e');
      return {'success': false, 'message': 'Failed to fetch amenities: $e'};
    }
  }
}
