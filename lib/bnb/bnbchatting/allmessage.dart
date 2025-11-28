import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/models/chat_model.dart';
import 'package:bnbfrontendflutter/models/booking_model.dart';
import 'package:bnbfrontendflutter/services/chat_service.dart';
import 'package:bnbfrontendflutter/services/booking_service.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/bnb/bnbchatting/messagechat.dart';
import 'package:bnbfrontendflutter/bnb/bnbchatting/startingconvo.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:intl/intl.dart';

class AllMessage extends StatefulWidget {
  const AllMessage({super.key});

  @override
  State<AllMessage> createState() => _AllMessageState();
}

class _AllMessageState extends State<AllMessage> {
  List<ChatModel> _chats = [];
  List<BookingModel> _activeBookings = [];
  bool _isLoading = true;
  bool _isLoadingBookings = false;
  int? _customerId;

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    try {
      // Get customer ID directly from shared preferences
      final customerId = await UserPreferences.getCustomerId();

      debugPrint('Loaded customer ID: $customerId');

      if (customerId != null) {
        setState(() {
          _customerId = customerId;
        });
        await _loadChats();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Error: No customer ID found. Please log in again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading customer ID: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadChats() async {
    if (_customerId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ChatService.getCustomerChats(
        customerId: _customerId,
        context: context,
      );

      if (mounted) {
        setState(() {
          if (response['success'] == true) {
            final List<ChatModel> chats = response['data'] as List<ChatModel>;
            // Sort chats by most recent activity (last message or updated time)
            _chats = _sortChatsByRecent(chats);
          } else {
            _chats = [];
          }
          _isLoading = false;
        });

        // If no chats, load active bookings
        if (_chats.isEmpty) {
          _loadActiveBookings();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading chats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadActiveBookings() async {
    if (_customerId == null) return;

    setState(() {
      _isLoadingBookings = true;
    });

    try {
      final response = await BookingService.getCustomerBookings(
        _customerId!,
        page: 1,
        limit: 50,
      );

      if (mounted) {
        if (response['success'] == true) {
          final List<dynamic> bookingsData = response['data'] ?? [];
          final bookings = bookingsData
              .map((booking) => BookingModel.fromJson(booking))
              .toList();

          // Filter for active bookings (current or upcoming, not cancelled)
          final activeBookings = bookings.where((booking) {
            return (booking.isCurrent || booking.isUpcoming) &&
                booking.status.toLowerCase() != 'cancelled';
          }).toList();

          setState(() {
            _activeBookings = activeBookings;
            _isLoadingBookings = false;
          });
        } else {
          setState(() {
            _activeBookings = [];
            _isLoadingBookings = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBookings = false;
        });
        debugPrint('Error loading active bookings: $e');
      }
    }
  }

  Future<void> _startChatFromBooking(BookingModel booking) async {
    if (_customerId == null) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: earthGreen)),
    );

    try {
      // Create or get chat for this booking
      final response = await ChatService.createOrGetChat(
        bookingId: booking.id,
        motelId: booking.motel.id,
        startedBy: 'customer',
        context: context,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (response['success'] == true && response['data'] != null) {
          // Navigate to chat screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageChat(
                bookingId: booking.id,
                motelId: booking.motel.id,
                motelName: booking.motel.name,
                onMessageSent: () {
                  // Refresh chats immediately when a message is sent
                  _refreshChats();
                },
              ),
            ),
          ).then((_) {
            // Refresh chats when returning
            _refreshChats();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to start chat'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshChats() async {
    if (_customerId == null) return;

    try {
      final response = await ChatService.getCustomerChats(
        customerId: _customerId,
        context: context,
      );

      if (mounted) {
        setState(() {
          if (response['success'] == true) {
            final List<ChatModel> chats = response['data'] as List<ChatModel>;
            // Sort chats by most recent activity (last message or updated time)
            _chats = _sortChatsByRecent(chats);
          } else {
            _chats = [];
          }
        });

        // If no chats, load active bookings
        if (_chats.isEmpty) {
          await _loadActiveBookings();
        }
      }
    } catch (e) {
      debugPrint('Error refreshing chats: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing chats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<ChatModel> _sortChatsByRecent(List<ChatModel> chats) {
    // Sort chats by most recent activity
    // Priority: lastMessage.createdAt > updatedAt > createdAt
    chats.sort((a, b) {
      DateTime? aTime;
      DateTime? bTime;

      // Get the most recent time for chat A
      if (a.lastMessage?.createdAt != null) {
        try {
          aTime = DateTime.parse(a.lastMessage!.createdAt!);
        } catch (_) {}
      }
      if (aTime == null && a.updatedAt != null) {
        try {
          aTime = DateTime.parse(a.updatedAt!);
        } catch (_) {}
      }
      if (aTime == null && a.createdAt != null) {
        try {
          aTime = DateTime.parse(a.createdAt!);
        } catch (_) {}
      }

      // Get the most recent time for chat B
      if (b.lastMessage?.createdAt != null) {
        try {
          bTime = DateTime.parse(b.lastMessage!.createdAt!);
        } catch (_) {}
      }
      if (bTime == null && b.updatedAt != null) {
        try {
          bTime = DateTime.parse(b.updatedAt!);
        } catch (_) {}
      }
      if (bTime == null && b.createdAt != null) {
        try {
          bTime = DateTime.parse(b.createdAt!);
        } catch (_) {}
      }

      // Sort descending (most recent first)
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1; // Put chats without time at the end
      if (bTime == null) return -1;
      return bTime.compareTo(aTime); // Descending order
    });

    return chats;
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(date);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(date);
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartChatBottomSheet(context),
        icon: const Icon(Icons.chat_bubble_outline, color: softCream),
        label: const Text(
          "Start Chat",
          style: TextStyle(fontWeight: FontWeight.bold, color: softCream),
        ),
        backgroundColor: earthGreen,
        elevation: 6,
      ),

      appBar: AppBar(
        backgroundColor: deepTerracotta,
        foregroundColor: softCream,
        title: const Text(
          'Messages',
          style: TextStyle(color: softCream, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: earthGreen))
          : _chats.isEmpty
          ? _isLoadingBookings
                ? const Center(
                    child: CircularProgressIndicator(color: earthGreen),
                  )
                : _activeBookings.isEmpty
                ? RefreshIndicator(
                    onRefresh: _refreshChats,
                    color: deepTerracotta,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: Center(
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
                                'Start a conversation with a motel',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textDark.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshChats,
                    color: earthGreen,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: earthGreen.withOpacity(0.1),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: earthGreen,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You can chat with these motels about your active bookings:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            itemCount: _activeBookings.length,
                            itemBuilder: (context, index) {
                              final booking = _activeBookings[index];
                              return _buildBookingItem(booking);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
          : RefreshIndicator(
              onRefresh: _refreshChats,
              color: earthGreen,
              child: _chats.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: const Center(
                          child: Text(
                            'No chats yet',
                            style: TextStyle(color: textDark),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _chats.length,
                      itemBuilder: (context, index) {
                        final chat = _chats[index];
                        return _buildChatItem(chat);
                      },
                    ),
            ),
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final lastMessage = chat.lastMessage;
    final motelImage = chat.motel.frontImage;
    final motelName = chat.motel.name;
    final lastMessageText = lastMessage?.message ?? 'No messages yet';
    final lastMessageTime = _formatTime(
      lastMessage?.createdAt ?? chat.updatedAt,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageChat(
              bookingId: chat.bookingId,
              motelId: chat.motelId,
              motelName: motelName,
              onMessageSent: () {
                // Refresh chats immediately when a message is sent
                _refreshChats();
              },
            ),
          ),
        ).then((_) {
          // Refresh chats when returning from message screen
          _refreshChats();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Motel Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: earthGreen.withOpacity(0.1),
              ),
              child: motelImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Showimage.networkImage(imageUrl: motelImage),
                    )
                  : const Icon(Icons.hotel, color: earthGreen, size: 30),
            ),
            const SizedBox(width: 12),
            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    motelName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessageText,
                    style: TextStyle(
                      fontSize: 14,
                      color: textDark.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Time
            Text(
              lastMessageTime,
              style: TextStyle(fontSize: 12, color: textDark.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(BookingModel booking) {
    final motelName = booking.motel.name;
    final checkInDate = DateTime.tryParse(booking.checkInDate);
    final checkOutDate = DateTime.tryParse(booking.checkOutDate);
    final isCurrent = booking.isCurrent;
    final isUpcoming = booking.isUpcoming;

    String statusText = '';
    Color statusColor = earthGreen;
    if (isCurrent) {
      statusText = 'Current Stay';
      statusColor = earthGreen;
    } else if (isUpcoming) {
      statusText = 'Upcoming';
      statusColor = Colors.blue;
    }

    String dateRange = '';
    if (checkInDate != null && checkOutDate != null) {
      dateRange =
          '${DateFormat('MMM d').format(checkInDate)} - ${DateFormat('MMM d, y').format(checkOutDate)}';
    }

    return InkWell(
      onTap: () => _startChatFromBooking(booking),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: earthGreen.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Motel Icon/Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: earthGreen.withOpacity(0.1),
              ),
              child: const Icon(Icons.hotel, color: earthGreen, size: 30),
            ),
            const SizedBox(width: 12),
            // Booking Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          motelName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (dateRange.isNotEmpty)
                    Text(
                      dateRange,
                      style: TextStyle(
                        fontSize: 12,
                        color: textDark.withOpacity(0.6),
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: earthGreen,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tap to start chatting',
                        style: TextStyle(
                          fontSize: 12,
                          color: earthGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: textDark.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: softCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: StartingConvo(
            customerId: _customerId!,
            scrollController: scrollController,
            onBookingSelected: (booking) {
              Navigator.pop(context); // Close bottom sheet
              _startChatFromBooking(booking as BookingModel);
            },
          ),
        ),
      ),
    );
  }
}
