import 'dart:convert';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingService {
  // Check room availability
  static Future<Map<String, dynamic>> checkRoomAvailability({
    required int roomId,
    required String checkInDate,
    required String checkOutDate,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/check-room-availability');

      debugPrint('Checking room availability: $url');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'room_id': roomId,
              'check_in_date': checkInDate,
              'check_out_date': checkOutDate,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Check Room Availability Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to check room availability',
          'error': response.body,
        };
      }
    } catch (e) {
      debugPrint('Error checking room availability: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Create booking and process payment
  static Future<Map<String, dynamic>> createBookingAndProcessPayment({
    required int roomId,
    required int customerId,
    required String checkInDate,
    required String checkOutDate,
    required String contactNumber,
    required String paymentMethod,
    String? paymentReference,
    String? specialRequests,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/create-booking');

      debugPrint('Creating booking: $url');

      final requestBody = {
        'room_id': roomId,
        'customer_id': customerId,
        'check_in_date': checkInDate,
        'check_out_date': checkOutDate,
        'contact_number': contactNumber,
        'payment_method': paymentMethod,
        'payment_reference': paymentReference,
        'special_requests': specialRequests,
      };

      debugPrint('Request Body: $requestBody');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Create Booking Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return responseData;
      } else {
        // Handle validation errors (422) or other errors
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create booking',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      debugPrint('Error creating booking: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Retry payment for failed booking
  static Future<Map<String, dynamic>> retryPayment({
    required int bookingId,
    required String paymentMethod,
    String? paymentReference,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/retry-payment/$bookingId');

      debugPrint('Retrying payment for booking: $bookingId');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'payment_method': paymentMethod,
              'payment_reference': paymentReference,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Retry Payment Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'message': errorResponse['message'] ?? 'Failed to retry payment',
        };
      }
    } catch (e) {
      debugPrint('Error retrying payment: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get booking details
  static Future<Map<String, dynamic>> getBookingDetails(int bookingId) async {
    try {
      final url = Uri.parse('$baseUrl/booking/$bookingId');

      debugPrint('Getting booking details: $url');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      debugPrint('Get Booking Details Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to get booking details'};
      }
    } catch (e) {
      debugPrint('Error getting booking details: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get customer bookings
  static Future<Map<String, dynamic>> getCustomerBookings(
    int customerId, {
    int page = 1,
    int limit = 10,
    String? filter,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (filter != null && filter.isNotEmpty) 'filter': filter,
      };

      final url = Uri.parse(
        '$baseUrl/booking/customer/$customerId',
      ).replace(queryParameters: queryParameters);

      debugPrint('Fetching customer bookings: $url');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      debugPrint(
        'Customer Bookings API Response Status: ${response.statusCode}',
      );
      debugPrint('Customer Bookings API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch customer bookings',
        };
      }
    } catch (e) {
      debugPrint('Error fetching customer bookings: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getCustomerTransactions(
    int customerId, {
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final url = Uri.parse(
        '$baseUrl/booking/customer/$customerId/transactions',
      ).replace(queryParameters: queryParameters);

      debugPrint('Fetching customer transactions: $url');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      debugPrint(
        'Customer Transactions API Response Status: ${response.statusCode}',
      );
      debugPrint('Customer Transactions API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch customer transactions',
        };
      }
    } catch (e) {
      debugPrint('Error fetching customer transactions: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Cancel booking (legacy method)
  static Future<Map<String, dynamic>> cancelBookingLegacy({
    required int bookingId,
    required int customerId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/booking/cancel');

      debugPrint('Canceling booking: $url');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              'booking_id': bookingId,
              'customer_id': customerId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('Cancel Booking API Response Status: ${response.statusCode}');
      debugPrint('Cancel Booking API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to cancel booking'};
      }
    } catch (e) {
      debugPrint('Error canceling booking: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
