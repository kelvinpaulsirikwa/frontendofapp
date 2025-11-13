import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/models/booking_model.dart';
import 'package:bnbfrontendflutter/services/booking_service.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';

class UpcomingBooking extends StatefulWidget {
  const UpcomingBooking({super.key});

  @override
  State<UpcomingBooking> createState() => _UpcomingBookingState();
}

class _UpcomingBookingState extends State<UpcomingBooking> {
  List<BookingModel> _upcomingBookings = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  int? _customerId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeCustomer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore &&
        !_isLoadingMore) {
      _loadMoreBookings();
    }
  }

  Future<void> _initializeCustomer() async {
    final customerId = await UserPreferences.getCustomerId();

    if (!mounted) return;

    if (customerId == null) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final local = AppLocalizations.of(context)!;
        _showErrorSnackBar(local.missingCustomerIdBookings);
      });
      return;
    }

    setState(() {
      _customerId = customerId;
    });

    await _loadUpcomingBookings(resetPage: true);
  }

  Future<void> _loadUpcomingBookings({bool resetPage = false}) async {
    if (_customerId == null) return;
    final local = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      if (resetPage) {
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      final response = await BookingService.getCustomerBookings(
        _customerId!,
        page: _currentPage,
        limit: 10,
        filter: 'upcoming',
      );

      if (response['success'] == true) {
        final List<dynamic> bookingsData = response['data'] ?? [];
        final bookings = bookingsData
            .map((booking) => BookingModel.fromJson(booking))
            .toList();

        setState(() {
          _upcomingBookings = bookings;
          _hasMore = response['pagination']?['has_more'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar(response['message'] ?? local.failedToLoadBookings);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(local.errorLoadingBookings('$e'));
    }
  }

  Future<void> _loadMoreBookings() async {
    if (!_hasMore || _isLoadingMore || _customerId == null) return;
    final local = AppLocalizations.of(context)!;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await BookingService.getCustomerBookings(
        _customerId!,
        page: nextPage,
        limit: 10,
        filter: 'upcoming',
      );

      if (response['success'] == true) {
        final List<dynamic> bookingsData = response['data'] ?? [];
        final bookings = bookingsData
            .map((booking) => BookingModel.fromJson(booking))
            .toList();

        setState(() {
          _upcomingBookings.addAll(bookings);
          _currentPage = nextPage;
          _hasMore = response['pagination']?['has_more'] ?? false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
        _showErrorSnackBar(
          response['message'] ?? local.failedToLoadMoreBookings,
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar(local.errorLoadingMoreBookings('$e'));
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: warmSand,
      appBar: SingleMGAppBar(
        local.upcomingBookingsTitle,
        context: context,
        isTitleCentered: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _upcomingBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 80,
                    color: textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    local.noBookingsFound,
                    style: const TextStyle(
                      color: textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    local.noBookingsResponse,
                    style: TextStyle(
                      color: textLight.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _loadUpcomingBookings(resetPage: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _upcomingBookings.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _upcomingBookings.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final booking = _upcomingBookings[index];
                  return _buildBookingCard(booking, local);
                },
              ),
            ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, AppLocalizations local) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: softCream,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: richBrown.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.motel.name,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.motel.address}, ${booking.motel.district}',
                        style: const TextStyle(color: textLight, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(booking.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.bed, color: earthGreen, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${booking.room.roomNumber} - ${booking.room.roomType}',
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: earthGreen, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${booking.checkInDate} - ${booking.checkOutDate}',
                  style: const TextStyle(color: textDark, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.nights_stay, color: earthGreen, size: 16),
                const SizedBox(width: 8),
                Text(
                  local.nightCount(booking.numberOfNights),
                  style: const TextStyle(color: textDark, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  'TZS ${booking.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: earthGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return earthGreen;
      case 'pending':
        return accentGold;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return deepTerracotta;
      default:
        return textLight;
    }
  }
}
