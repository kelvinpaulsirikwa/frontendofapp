import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

class BookingService {
  // Check room availability
  static Future<Map<String, dynamic>> checkRoomAvailability({
    required int roomId,
    required String checkInDate,
    required String checkOutDate,
    BuildContext? context,
  }) async {
    debugPrint('Checking room availability for room: $roomId');

    final response = await ApiClient.post(
      '/check-room-availability',
      context: context,
      body: {
        'room_id': roomId,
        'check_in_date': checkInDate,
        'check_out_date': checkOutDate,
      },
    );

    debugPrint('Check Room Availability Response: $response');
    return response;
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
    BuildContext? context,
  }) async {
    debugPrint('Creating booking for room: $roomId');

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

    final response = await ApiClient.post(
      '/create-booking',
      context: context,
      body: requestBody,
    );

    debugPrint('Create Booking Response: $response');
    return response;
  }

  // Retry payment for failed booking
  static Future<Map<String, dynamic>> retryPayment({
    required int bookingId,
    required String paymentMethod,
    String? paymentReference,
    BuildContext? context,
  }) async {
    debugPrint('Retrying payment for booking: $bookingId');

    final response = await ApiClient.post(
      '/retry-payment/$bookingId',
      context: context,
      body: {
        'payment_method': paymentMethod,
        'payment_reference': paymentReference,
      },
    );

    debugPrint('Retry Payment Response: $response');
    return response;
  }

  // Get booking details
  static Future<Map<String, dynamic>> getBookingDetails(
    int bookingId, {
    BuildContext? context,
  }) async {
    debugPrint('Getting booking details for: $bookingId');

    final response = await ApiClient.get(
      '/booking/$bookingId',
      context: context,
    );

    debugPrint('Get Booking Details Response: $response');
    return response;
  }

  // Get customer bookings
  static Future<Map<String, dynamic>> getCustomerBookings(
    int customerId, {
    int page = 1,
    int limit = 10,
    String? filter,
    BuildContext? context,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (filter != null && filter.isNotEmpty) 'filter': filter,
    };

    debugPrint('Fetching customer bookings for: $customerId');

    final response = await ApiClient.get(
      '/booking/customer/$customerId',
      context: context,
      queryParams: queryParams,
    );

    debugPrint('Customer Bookings Response: $response');
    return response;
  }

  static Future<Map<String, dynamic>> getCustomerTransactions(
    int customerId, {
    int page = 1,
    int limit = 20,
    String? status,
    BuildContext? context,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null && status.isNotEmpty) 'status': status,
    };

    debugPrint('Fetching customer transactions for: $customerId');

    final response = await ApiClient.get(
      '/booking/customer/$customerId/transactions',
      context: context,
      queryParams: queryParams,
    );

    debugPrint('Customer Transactions Response: $response');
    return response;
  }

  // Cancel booking (legacy method)
  static Future<Map<String, dynamic>> cancelBookingLegacy({
    required int bookingId,
    required int customerId,
    BuildContext? context,
  }) async {
    debugPrint('Canceling booking: $bookingId');

    final response = await ApiClient.post(
      '/booking/cancel',
      context: context,
      body: {
        'booking_id': bookingId,
        'customer_id': customerId,
      },
    );

    debugPrint('Cancel Booking Response: $response');
    return response;
  }
}
