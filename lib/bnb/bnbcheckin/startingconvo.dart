import 'package:bnbfrontendflutter/bnb/bnbchatting/ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bnbfrontendflutter/services/booking_service.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';

class StartingConvo extends StatefulWidget {
  final int customerId;
  final ScrollController? scrollController;
  final Function(BookingModel)? onBookingSelected;

  const StartingConvo({
    super.key,
    required this.customerId,
    this.scrollController,
    this.onBookingSelected,
  });

  @override
  State<StartingConvo> createState() => _StartingConvoState();
}

class _StartingConvoState extends State<StartingConvo> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  List<BookingModel> _bookings = [];
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _loadBookings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreBookings();
    }
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await BookingService.getCustomerBookings(
        widget.customerId,
        page: 1,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final bookings = data
            .map((json) => BookingModel.fromJson(json))
            .toList();
        setState(() {
          _bookings = bookings;
          _isLoading = false;
          _hasMore = data.length >= 20;
        });
      } else {
        setState(() {
          _bookings = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading bookings: $e')));
    }
  }

  Future<void> _loadMoreBookings() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      _currentPage++;
      final response = await BookingService.getCustomerBookings(
        widget.customerId,
        page: _currentPage,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final moreBookings = data
            .map((json) => BookingModel.fromJson(json))
            .toList();
        setState(() {
          _bookings.addAll(moreBookings);
          _isLoadingMore = false;
          _hasMore = data.length >= 20;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  String _formatDate(String? date) {
    if (date == null) return "Not set";
    try {
      return DateFormat('MMM d, y').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: textDark.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Select a Booking to Start Chat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Booking list
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: earthGreen),
                )
              : _bookings.isEmpty
              ? const Center(
                  child: Text(
                    "No bookings found",
                    style: TextStyle(color: textDark),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _bookings.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(color: earthGreen),
                        ),
                      );
                    }
                    return BookingCard(
                      booking: _bookings[index],
                      onTap: () {
                        if (widget.onBookingSelected != null) {
                          widget.onBookingSelected!(_bookings[index]);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
