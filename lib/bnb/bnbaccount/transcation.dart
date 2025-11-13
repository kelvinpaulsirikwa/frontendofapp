import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:bnbfrontendflutter/models/booking_model.dart';
import 'package:bnbfrontendflutter/services/booking_service.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:flutter/material.dart';

class TranscationDetails extends StatefulWidget {
  const TranscationDetails({super.key});

  @override
  State<TranscationDetails> createState() => _TranscationDetailsState();
}

class _TranscationDetailsState extends State<TranscationDetails> {
  List<TransactionInfo> _transactions = [];
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
      _loadMoreTransactions();
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
        _showErrorSnackBar(local.missingCustomerIdTransactions);
      });
      return;
    }

    setState(() {
      _customerId = customerId;
    });

    await _loadTransactions(resetPage: true);
  }

  Future<void> _loadTransactions({bool resetPage = false}) async {
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
      final response = await BookingService.getCustomerTransactions(
        _customerId!,
        page: _currentPage,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> transactionsData = response['data'] ?? [];
        final transactions = transactionsData
            .map((transaction) => TransactionInfo.fromJson(transaction))
            .toList();

        setState(() {
          _transactions = transactions;
          _hasMore = response['pagination']?['has_more'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar(
          response['message'] ?? local.failedToLoadTransactions,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(local.errorLoadingTransactions('$e'));
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (!_hasMore || _isLoadingMore || _customerId == null) return;
    final local = AppLocalizations.of(context)!;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await BookingService.getCustomerTransactions(
        _customerId!,
        page: nextPage,
        limit: 20,
      );

      if (response['success'] == true) {
        final List<dynamic> transactionsData = response['data'] ?? [];
        final newTransactions = transactionsData
            .map((transaction) => TransactionInfo.fromJson(transaction))
            .toList();

        final existingIds = _transactions.map((tx) => tx.id).toSet();

        setState(() {
          _transactions.addAll(
            newTransactions.where((tx) => !existingIds.contains(tx.id)),
          );
          _currentPage = nextPage;
          _hasMore = response['pagination']?['has_more'] ?? false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
        _showErrorSnackBar(
          response['message'] ?? local.failedToLoadMoreTransactions,
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar(local.errorLoadingMoreTransactions('$e'));
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
        local.transactionHistoryTitle,
        context: context,
        isTitleCentered: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: textLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    local.noTransactionsFound,
                    style: const TextStyle(
                      color: textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    local.noTransactionsDescription,
                    style: TextStyle(
                      color: textLight.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _loadTransactions(resetPage: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _transactions.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final transaction = _transactions[index];
                  return _buildTransactionCard(transaction, local);
                },
              ),
            ),
    );
  }

  Widget _buildTransactionCard(
    TransactionInfo transaction,
    AppLocalizations local,
  ) {
    final booking = transaction.booking;
    final customer = booking?.customer;
    final motel = booking?.motel;
    final room = booking?.room;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.transactionId,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        local.paymentMethodLabel(
                          transaction.paymentMethodDisplay,
                        ),
                        style: const TextStyle(color: textLight, fontSize: 13),
                      ),
                      if (transaction.paymentReference != null &&
                          transaction.paymentReference!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          local.referenceLabel(transaction.paymentReference!),
                          style: const TextStyle(
                            color: textLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.statusDisplay,
                    style: TextStyle(
                      color: _getStatusColor(transaction.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.attach_money,
              label: local.amountLabel,
              value: 'TZS ${transaction.amount.toStringAsFixed(0)}',
              valueStyle: const TextStyle(
                color: earthGreen,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (transaction.processedAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.schedule,
                label: local.processedLabel,
                value: _formatDate(transaction.processedAt!),
              ),
            ],
            if (transaction.createdAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: local.createdLabel,
                value: _formatDate(transaction.createdAt!),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                local.transactionStatusMessage(
                  transaction.statusDisplay.toLowerCase(),
                ),
                style: const TextStyle(
                  color: textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (booking != null) ...[
              const SizedBox(height: 18),
              Text(
                local.bookingDetailsTitle,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.confirmation_number_outlined,
                label: local.bookingReferenceLabel,
                value: booking.bookingReference,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.event,
                label: local.stayDatesLabel,
                value:
                    '${booking.checkInDate ?? '-'} - ${booking.checkOutDate ?? '-'}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.nights_stay,
                label: local.nightsLabel,
                value: '${booking.numberOfNights}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.payments_outlined,
                label: local.stayTotalLabel,
                value: 'TZS ${booking.totalAmount.toStringAsFixed(0)}',
                valueStyle: const TextStyle(
                  color: textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (motel != null) ...[
                const SizedBox(height: 16),
                Text(
                  local.propertySectionTitle,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.home_work_outlined,
                  label: local.nameLabel,
                  value: motel.name,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: local.addressLabel,
                  value: '${motel.address}, ${motel.district}',
                ),
              ],
              if (room != null) ...[
                const SizedBox(height: 16),
                Text(
                  local.roomSectionTitle,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.meeting_room_outlined,
                  label: local.roomLabel,
                  value: '${room.roomType} • ${room.roomNumber}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.attach_money_outlined,
                  label: local.pricePerNightLabel,
                  value: 'TZS ${room.pricePerNight.toStringAsFixed(0)}',
                ),
              ],
              if (customer != null) ...[
                const SizedBox(height: 16),
                Text(
                  local.guestSectionTitle,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: local.nameLabel,
                  value: customer.username,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: local.emailLabel,
                  value: customer.email,
                ),
                if (customer.phoneNumber != null &&
                    customer.phoneNumber!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    label: local.phoneLabel,
                    value: customer.phoneNumber!,
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return earthGreen;
      case 'pending':
        return accentGold;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return deepTerracotta;
      default:
        return textLight;
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: earthGreen, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    valueStyle ??
                    const TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      final local = AppLocalizations.of(context)!;

      if (difference.inDays > 0) {
        return local.timeAgoDays(difference.inDays);
      } else if (difference.inHours > 0) {
        return local.timeAgoHours(difference.inHours);
      } else if (difference.inMinutes > 0) {
        return local.timeAgoMinutes(difference.inMinutes);
      } else {
        return local.timeAgoJustNow;
      }
    } catch (e) {
      return dateString;
    }
  }
}
