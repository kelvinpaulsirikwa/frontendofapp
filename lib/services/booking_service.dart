import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';

class BookingService {
  /// Format date for API (YYYY-MM-DD)
  static String _fmt(DateTime d) => d.toIso8601String().split('T')[0];

  /// Create a single booking and process payment.
  /// Used for "Today" mode: check-in today, until date X.
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

    final response = await ApiClient.post(
      '/create-booking',
      context: context,
      body: requestBody,
    );

    return response;
  }

  /// Create multiple bookings for "Pick Dates" mode.
  /// Calls independent API endpoint with list of selected dates (one request).
  /// Each date = one night. Backend creates one booking per date.
  static Future<Map<String, dynamic>> createBookingsForPickDates({
    required int roomId,
    required int customerId,
    required List<DateTime> selectedDates,
    required String contactNumber,
    required String paymentMethod,
    String? paymentReference,
    String? specialRequests,
    BuildContext? context,
  }) async {
    if (selectedDates.isEmpty) {
      return {'success': false, 'message': 'No dates selected.'};
    }

    final selectedDatesFormatted = selectedDates
        .map((d) => _fmt(d))
        .toList()
      ..sort();

    final requestBody = {
      'room_id': roomId,
      'customer_id': customerId,
      'selected_dates': selectedDatesFormatted,
      'contact_number': contactNumber,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'special_requests': specialRequests,
    };

    final response = await ApiClient.post(
      '/create-multiple-bookings',
      context: context,
      body: requestBody,
    );

    return response;
  }

  /// Check room availability for a date range
  static Future<Map<String, dynamic>> checkRoomAvailability({
    required int roomId,
    required String checkInDate,
    required String checkOutDate,
    BuildContext? context,
  }) async {
    final response = await ApiClient.post(
      '/check-room-availability',
      context: context,
      body: {
        'room_id': roomId,
        'check_in_date': checkInDate,
        'check_out_date': checkOutDate,
      },
    );

    return response;
  }

  /// Get a single booking by ID
  static Future<Map<String, dynamic>> getBookingDetails(
    int bookingId, {
    BuildContext? context,
  }) async {
    return ApiClient.get('/booking/$bookingId', context: context);
  }

  /// Get bookings for a customer (paginated)
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

    return ApiClient.get(
      '/booking/customer/$customerId',
      context: context,
      queryParams: queryParams,
    );
  }

  /// Get transactions for a customer
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

    return ApiClient.get(
      '/booking/customer/$customerId/transactions',
      context: context,
      queryParams: queryParams,
    );
  }

  /// Retry payment for a failed booking
  static Future<Map<String, dynamic>> retryPayment({
    required int bookingId,
    required String paymentMethod,
    String? paymentReference,
    BuildContext? context,
  }) async {
    return ApiClient.post(
      '/retry-payment/$bookingId',
      context: context,
      body: {
        'payment_method': paymentMethod,
        'payment_reference': paymentReference,
      },
    );
  }

  /// Cancel a booking
  static Future<Map<String, dynamic>> cancelBooking({
    required int bookingId,
    required int customerId,
    BuildContext? context,
  }) async {
    return ApiClient.post(
      '/booking/cancel',
      context: context,
      body: {
        'booking_id': bookingId,
        'customer_id': customerId,
      },
    );
  }

  /// @deprecated Use [cancelBooking] instead
  static Future<Map<String, dynamic>> cancelBookingLegacy({
    required int bookingId,
    required int customerId,
    BuildContext? context,
  }) =>
      cancelBooking(bookingId: bookingId, customerId: customerId, context: context);
}
