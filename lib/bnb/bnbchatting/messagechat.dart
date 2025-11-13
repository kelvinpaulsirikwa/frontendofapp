import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/models/message_model.dart';
import 'package:bnbfrontendflutter/services/chat_service.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:intl/intl.dart';

class MessageChat extends StatefulWidget {
  final int? bookingId;
  final int motelId;
  final String? motelName;
  final VoidCallback? onMessageSent;

  const MessageChat({
    super.key,
    this.bookingId,
    required this.motelId,
    this.motelName,
    this.onMessageSent,
  });

  @override
  State<MessageChat> createState() => _MessageChatState();
}

class _MessageChatState extends State<MessageChat> {
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  int? _chatId;
  int _currentPage = 1;
  bool _hasMore = true;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
    _scrollController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // Load more messages when scrolling to top (oldest messages)
    if (_scrollController.hasClients &&
        _scrollController.position.pixels <=
            _scrollController.position.maxScrollExtent * 0.2 &&
        _hasMore &&
        !_isLoadingMore) {
      _loadMoreMessages();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _pollForNewMessages(),
    );
  }

  Future<void> _loadMoreMessages() async {
    if (_chatId == null || !_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final messagesResponse = await ChatService.getChatMessages(
        _chatId!,
        page: _currentPage,
        limit: 50,
      );

      if (mounted) {
        if (messagesResponse['success'] == true) {
          final newMessages = messagesResponse['data'] as List<MessageModel>;
          final pagination =
              messagesResponse['pagination'] as Map<String, dynamic>?;

          setState(() {
            // Add older messages to the beginning of the list (top)
            _messages.insertAll(0, newMessages);
            _hasMore = pagination?['has_more'] ?? false;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _hasMore = false;
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        debugPrint('Error loading more messages: $e');
      }
    }
  }

  Future<void> _pollForNewMessages() async {
    if (_chatId == null ||
        _isLoading ||
        _isLoadingMore ||
        _isSending ||
        _isRefreshing) {
      return;
    }

    _isRefreshing = true;

    try {
      final response = await ChatService.getChatMessages(
        _chatId!,
        page: 1,
        limit: 50,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        final latestMessages = response['data'] as List<MessageModel>;

        if (latestMessages.isEmpty) {
          return;
        }

        final existingIds = _messages.map((message) => message.id).toSet();
        final newMessages = latestMessages
            .where((message) => !existingIds.contains(message.id))
            .toList();

        if (newMessages.isNotEmpty) {
          setState(() {
            _messages.addAll(newMessages);
          });

          if (_scrollController.hasClients) {
            final position = _scrollController.position;
            final threshold = position.maxScrollExtent - 100;

            if (position.pixels >= threshold) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error polling messages: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Get or create the chat based on bookingId, motelId, and customerId
      final chatResponse = await ChatService.createOrGetChat(
        bookingId: widget.bookingId,
        motelId: widget.motelId,
      );

      if (!mounted) return;

      if (chatResponse['success'] == true && chatResponse['data'] != null) {
        final chatData = chatResponse['data'];
        final chatId = chatData['chat_id'] ?? chatData['id'];

        setState(() {
          _chatId = chatId as int;
        });

        // Step 2: Get messages for this chat ID with pagination
        final messagesResponse = await ChatService.getChatMessages(
          chatId,
          page: 1,
          limit: 50, // Load first 50 messages
        );

        if (mounted) {
          setState(() {
            if (messagesResponse['success'] == true) {
              // Service already returns messages in oldest-first order
              _messages = messagesResponse['data'] as List<MessageModel>;
              // Check if there are more messages to load
              final pagination =
                  messagesResponse['pagination'] as Map<String, dynamic>?;
              _hasMore = pagination?['has_more'] ?? false;
              _currentPage = 1;
            } else {
              // If messages fail to load but chat exists, just set empty list
              // User can still send messages
              _messages = [];
              _hasMore = false;
            }
            _isLoading = false;
          });

          // Add scroll listener for pagination
          _scrollController.addListener(_onScroll);

          // Scroll to bottom after loading (only if there are messages)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && _messages.isNotEmpty) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        // If chat creation fails, still allow user to try sending (which will retry chat creation)
        if (mounted) {
          setState(() {
            _messages = [];
            _isLoading = false;
            // Don't set _chatId to null, let _sendMessage handle chat creation
          });
          // Don't show error here - let user try to send a message which will create the chat
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      // If chatId is null, create or get the chat first
      int? chatIdToUse = _chatId;

      if (chatIdToUse == null) {
        // Step 1: Create or get the chat
        final chatResponse = await ChatService.createOrGetChat(
          bookingId: widget.bookingId,
          motelId: widget.motelId,
        );

        if (!mounted) {
          setState(() {
            _isSending = false;
          });
          return;
        }

        if (chatResponse['success'] == true && chatResponse['data'] != null) {
          final chatData = chatResponse['data'];
          chatIdToUse = chatData['chat_id'] ?? chatData['id'];

          setState(() {
            _chatId = chatIdToUse;
          });
        } else {
          if (mounted) {
            setState(() {
              _isSending = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  chatResponse['message'] ?? 'Failed to create chat',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Step 2: Send the message
      final response = await ChatService.sendMessage(
        chatId: chatIdToUse!,
        message: messageText,
      );

      if (mounted) {
        if (response['success'] == true) {
          _messageController.clear();
          // Add the new message to the end of the list (bottom - newest)
          final newMessage = response['data'] as MessageModel;
          setState(() {
            _messages.add(newMessage);
          });

          // Notify parent that a message was sent (to refresh chat list)
          if (widget.onMessageSent != null) {
            widget.onMessageSent!();
          }

          // Scroll to bottom (newest message)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to send message'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isSending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatMessageTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(date);
      } else if (difference.inDays == 1) {
        return 'Yesterday ${DateFormat('HH:mm').format(date)}';
      } else {
        return DateFormat('MMM d, HH:mm').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: earthGreen,
        foregroundColor: softCream,
        title: Text(
          widget.motelName ?? 'Chat',
          style: const TextStyle(color: softCream, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: earthGreen),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: textDark.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: textDark.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation',
                          style: TextStyle(
                            fontSize: 14,
                            color: textDark.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse:
                        false, // Normal order: oldest at top, newest at bottom
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the top (index 0) when loading older messages
                      if (_isLoadingMore && index == 0) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(color: earthGreen),
                          ),
                        );
                      }
                      // Adjust index if loading indicator is shown
                      final messageIndex = _isLoadingMore ? index - 1 : index;
                      final message = _messages[messageIndex];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: textDark.withOpacity(0.4)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: earthGreen.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: earthGreen.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: earthGreen,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: earthGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  softCream,
                                ),
                              ),
                            )
                          : const Icon(Icons.send, color: softCream),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isFromCustomer = message.isFromCustomer;
    final messageText = message.message;
    final messageTime = _formatMessageTime(message.createdAt);

    return Align(
      alignment: isFromCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isFromCustomer ? earthGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isFromCustomer ? 16 : 4),
            bottomRight: Radius.circular(isFromCustomer ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              messageText,
              style: TextStyle(
                fontSize: 15,
                color: isFromCustomer ? softCream : textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              messageTime,
              style: TextStyle(
                fontSize: 11,
                color: isFromCustomer
                    ? softCream.withOpacity(0.7)
                    : textDark.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
