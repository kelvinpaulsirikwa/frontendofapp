import 'package:bnbfrontendflutter/services/api_client.dart';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  // Get all chats for a customer (motels they've chatted with)
  static Future<Map<String, dynamic>> getCustomerChats({
    int? customerId,
    BuildContext? context,
  }) async {
    final response = await ApiClient.get(
      '/customer/chats',
      context: context,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> chatsJson = response['data'];
      final List<ChatModel> chats = chatsJson
          .map((chat) => ChatModel.fromJson(chat))
          .toList();

      return {
        'success': true,
        'data': chats,
        'message': response['message'] ?? 'Chats retrieved successfully',
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to retrieve chats',
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
    BuildContext? context,
  }) async {
    Map<String, String> queryParams = {};
    if (getAll) {
      queryParams['all'] = 'true';
    } else {
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
    }

    final response = await ApiClient.get(
      '/chat/$chatId/messages',
      context: context,
      queryParams: queryParams,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> messagesJson = response['data'];
      final List<MessageModel> messages = messagesJson
          .map((message) => MessageModel.fromJson(message))
          .toList();

      return {
        'success': true,
        'data': messages.reversed.toList(), // Reverse to show oldest first
        'pagination': response['pagination'] ?? {},
        'message': response['message'] ?? 'Messages retrieved successfully',
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to retrieve messages',
        'data': <MessageModel>[],
      };
    }
  }

  // Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required int chatId,
    required String message,
    BuildContext? context,
  }) async {
    final requestBody = {'chat_id': chatId, 'message': message};
    final response = await ApiClient.post(
      '/chat/send-message',
      context: context,
      body: requestBody,
    );


    if (response['success'] == true && response['data'] != null) {
      return {
        'success': true,
        'data': MessageModel.fromJson(response['data']),
        'message': response['message'] ?? 'Message sent successfully',
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to send message',
        'errors': response['errors'] ?? {},
      };
    }
  }

  // Create or get existing chat
  static Future<Map<String, dynamic>> createOrGetChat({
    int? bookingId,
    required int motelId,
    String? startedBy,
    BuildContext? context,
  }) async {
    final requestBody = {
      if (bookingId != null) 'booking_id': bookingId,
      'motel_id': motelId,
      if (startedBy != null) 'started_by': startedBy,
    };

    final response = await ApiClient.post(
      '/chat/create-or-get',
      context: context,
      body: requestBody,
    );

    if (response['success'] == true && response['data'] != null) {
      return {
        'success': true,
        'data': response['data'],
        'message': response['message'] ?? 'Chat retrieved successfully',
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to create/get chat',
        'errors': response['errors'] ?? {},
      };
    }
  }
}
