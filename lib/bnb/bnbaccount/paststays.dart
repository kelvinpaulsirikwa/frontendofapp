import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:bnbfrontendflutter/models/booking_model.dart';
import 'package:bnbfrontendflutter/services/booking_service.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:flutter/material.dart';

class PastStays extends StatefulWidget {
  const PastStays({super.key});

  @override
  State<PastStays> createState() => _PastStaysState();
}

class _PastStaysState extends State<PastStays> {
  List<BookingModel> _pastStays = [];
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
      _loadMorePastStays();
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
        _showErrorSnackBar(local.missingCustomerIdPastStays);
      });
      return;
    }

    setState(() {
      _customerId = customerId;
    });

    await _loadPastStays(resetPage: true);
  }

  Future<void> _loadPastStays({bool resetPage = false}) async {
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
        filter: 'past',
      );

      if (response['success'] == true) {
        final List<dynamic> bookingsData = response['data'] ?? [];
        final pastStays = bookingsData
            .map((booking) => BookingModel.fromJson(booking))
            .toList();

        setState(() {
          _pastStays = pastStays;
          _hasMore = response['pagination']?['has_more'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar(response['message'] ?? local.failedToLoadPastStays);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(local.errorLoadingPastStays('$e'));
    }
  }

  Future<void> _loadMorePastStays() async {
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
        filter: 'past',
      );

      if (response['success'] == true) {
        final List<dynamic> bookingsData = response['data'] ?? [];
        final pastStays = bookingsData
            .map((booking) => BookingModel.fromJson(booking))
            .toList();

        setState(() {
          _pastStays.addAll(pastStays);
          _currentPage = nextPage;
          _hasMore = response['pagination']?['has_more'] ?? false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
        _showErrorSnackBar(
          response['message'] ?? local.failedToLoadMorePastStays,
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar(local.errorLoadingMorePastStays('$e'));
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
        local.pastBookingsAndStaysTitle,
        context: context,
        isTitleCentered: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pastStays.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined,
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
              onRefresh: () => _loadPastStays(resetPage: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _pastStays.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _pastStays.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final stay = _pastStays[index];
                  return _buildPastStayCard(stay, local);
                },
              ),
            ),
    );
  }

  Widget _buildPastStayCard(BookingModel stay, AppLocalizations local) {
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
                        stay.motel.name,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stay.motel.address}, ${stay.motel.district}',
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
                    color: earthGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: earthGreen,
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
                  '${stay.room.roomNumber} - ${stay.room.roomType}',
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
                  '${stay.checkInDate} - ${stay.checkOutDate}',
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
                  local.nightCount(stay.numberOfNights),
                  style: const TextStyle(color: textDark, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  'TZS ${stay.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: earthGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: earthGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      local.stayCompleted,
                      style: const TextStyle(color: textDark, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
