import 'dart:convert';
import 'package:bnbfrontendflutter/services/bnbconnection.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  // Helper method to get auth headers with token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await UserPreferences.getApiToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Get all chats for a customer (motels they've chatted with)
  static Future<Map<String, dynamic>> getCustomerChats([
    int? customerId,
  ]) async {
    try {
      final url = Uri.parse('$baseUrl/customer/chats');
      final headers = await _getAuthHeaders();

      debugPrint('Fetching customer chats: $url');

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      debugPrint('Get Customer Chats Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> chatsJson = responseData['data'];
          final List<ChatModel> chats = chatsJson
              .map((chat) => ChatModel.fromJson(chat))
              .toList();

          return {
            'success': true,
            'data': chats,
            'message':
                responseData['message'] ?? 'Chats retrieved successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to retrieve chats',
            'data': <ChatModel>[],
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch chats',
          'data': <ChatModel>[],
        };
      }
    } catch (e) {
      debugPrint('Error fetching customer chats: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': <ChatModel>[],
      };
    }
  }

  // Get messages for a specific chat
  static Future<Map<String, dynamic>> getChatMessages(
    int chatId, {
    int page = 1,
    int limit = 50,
    bool getAll = false, // New parameter to get all messages
  }) async {
    try {
      final url = getAll
          ? Uri.parse('$baseUrl/chat/$chatId/messages?all=true')
          : Uri.parse('$baseUrl/chat/$chatId/messages?page=$page&limit=$limit');

      debugPrint('Fetching chat messages: $url');
      final headers = await _getAuthHeaders();

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      debugPrint('Get Chat Messages Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> messagesJson = responseData['data'];
          final List<MessageModel> messages = messagesJson
              .map((message) => MessageModel.fromJson(message))
              .toList();

          return {
            'success': true,
            'data': messages.reversed.toList(), // Reverse to show oldest first
            'pagination': responseData['pagination'] ?? {},
            'message':
                responseData['message'] ?? 'Messages retrieved successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to retrieve messages',
            'data': <MessageModel>[],
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch messages',
          'data': <MessageModel>[],
        };
      }
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': <MessageModel>[],
      };
    }
  }

  // Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required int chatId,
    required String message,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat/send-message');
      final headers = await _getAuthHeaders();

      debugPrint('Sending message: $url');

      final requestBody = {'chat_id': chatId, 'message': message};

      debugPrint('Request Body: $requestBody');

      final response = await http
          .post(url, headers: headers, body: json.encode(requestBody))
          .timeout(const Duration(seconds: 30));

      debugPrint('Send Message Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          return {
            'success': true,
            'data': MessageModel.fromJson(responseData['data']),
            'message': responseData['message'] ?? 'Message sent successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to send message',
          };
        }
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send message',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Create or get existing chat
  static Future<Map<String, dynamic>> createOrGetChat({
    int? bookingId,
    required int motelId,
    String? startedBy,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat/create-or-get');
      final headers = await _getAuthHeaders();

      debugPrint('Creating or getting chat: $url');

      final requestBody = {
        if (bookingId != null) 'booking_id': bookingId,
        'motel_id': motelId,
        if (startedBy != null) 'started_by': startedBy,
      };

      debugPrint('Request Body: $requestBody');

      final response = await http
          .post(url, headers: headers, body: json.encode(requestBody))
          .timeout(const Duration(seconds: 30));

      debugPrint('Create or Get Chat Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          return {
            'success': true,
            'data': responseData['data'],
            'message': responseData['message'] ?? 'Chat retrieved successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to create/get chat',
          };
        }
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create/get chat',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      debugPrint('Error creating/getting chat: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
