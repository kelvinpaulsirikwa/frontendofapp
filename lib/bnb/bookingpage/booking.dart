import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/models/bnbroommodel.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/services/booking_service.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingPage extends StatefulWidget {
  final Room room;

  const BookingPage({super.key, required this.room});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bookerNumberController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  /// 'today' | 'pick_dates'
  String _bookingMode = 'today';
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  final List<DateTime> _selectedDates = [];
  final String _paymentMethod = 'mobile_money';

  DateTime get _today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime get _threeMonthsLater => _today.add(const Duration(days: 90));

  int get _numberOfNights {
    switch (_bookingMode) {
      case 'today':
        return _checkOutDate.difference(_checkInDate).inDays;
      case 'pick_dates':
        return _selectedDates.length;
      default:
        return 1;
    }
  }

  double get _totalPrice => widget.room.pricepernight * _numberOfNights;

  bool get _canSubmit {
    if (_bookingMode == 'pick_dates') {
      return _selectedDates.isNotEmpty;
    }
    return _numberOfNights >= 1;
  }

  @override
  void dispose() {
    _bookerNumberController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Widget _datePickerTheme(Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: earthGreen,
          onPrimary: softCream,
          surface: softCream,
          onSurface: textDark,
        ),
        dialogBackgroundColor: softCream,
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: _threeMonthsLater,
      builder: (context, child) => _datePickerTheme(child),
    );
    if (picked != null) {
      setState(() => _checkOutDate = picked);
    }
  }

  Future<void> _showPickDatesCalendar(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NonConsecutiveCalendarSheet(
        selectedDates: List.from(_selectedDates),
        today: _today,
        lastDate: _threeMonthsLater,
        onDone: (dates) {
          setState(() {
            _selectedDates.clear();
            _selectedDates.addAll(dates);
            _selectedDates.sort((a, b) => a.compareTo(b));
          });
        },
      ),
    );
  }

  void _removePickDatesDate(DateTime d) {
    setState(() {
      _selectedDates.removeWhere((x) =>
          x.year == d.year && x.month == d.month && x.day == d.day);
    });
  }

  String _fmt(DateTime d) => d.toIso8601String().split('T')[0];

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canSubmit) {
      _showErrorDialog('Please select at least one date.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: softCream,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: earthGreen),
              SizedBox(height: 20),
              Text(
                'Processing your booking...',
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final Map<String, dynamic> response;
      if (_bookingMode == 'pick_dates') {
        response = await BookingService.createBookingsForPickDates(
          roomId: widget.room.id,
          customerId: 1,
          selectedDates: List.from(_selectedDates),
          contactNumber: _bookerNumberController.text,
          paymentMethod: _paymentMethod,
          paymentReference: _mobileNumberController.text,
          specialRequests: null,
        );
      } else {
        response = await BookingService.createBookingAndProcessPayment(
          roomId: widget.room.id,
          customerId: 1,
          checkInDate: _fmt(_today),
          checkOutDate: _fmt(_checkOutDate),
          contactNumber: _bookerNumberController.text,
          paymentMethod: _paymentMethod,
          paymentReference: _mobileNumberController.text,
          specialRequests: null,
        );
      }

      debugPrint('Booking Response: $response');

      if (!mounted) return;
      Navigator.of(context).pop();

      if (response['success'] == false) {
        final errors = response['errors'];
        if (errors != null && errors is Map) {
          _showValidationErrorsDialog(
            Map<String, dynamic>.from(errors),
            response['message'] ?? 'Validation failed',
          );
        } else {
          _showBookingResultDialog(response);
        }
      } else {
        _showBookingResultDialog(response);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorDialog('Failed to process booking: $e');
      }
    }
  }

  void _showBookingResultDialog(Map<String, dynamic> response) {
    final isSuccess = response['success'] == true;
    final message = response['message'] ?? 'Unknown error';
    final bookingData = response['data']?['booking'];
    final transactionData = response['data']?['transaction'];
    final isPaymentFailed = transactionData?['status'] == 'failed';
    final isValidated =
        transactionData?['status'] == 'validated'; // Validation only, not saved

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: softCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSuccess && !isPaymentFailed
                    ? earthGreen.withOpacity(0.1)
                    : isPaymentFailed
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess && !isPaymentFailed
                    ? Icons.check_circle
                    : isPaymentFailed
                    ? Icons.payment
                    : Icons.error,
                color: isSuccess && !isPaymentFailed
                    ? earthGreen
                    : isPaymentFailed
                    ? Colors.orange
                    : Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSuccess && !isPaymentFailed && !isValidated
                  ? 'Booking Confirmed!'
                  : isSuccess && isValidated
                  ? 'Booking Validated!'
                  : isPaymentFailed
                  ? 'Payment Failed'
                  : 'Booking Failed',
              style: const TextStyle(
                color: textDark,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textLight, fontSize: 14),
            ),
            if (isSuccess && bookingData != null && !isPaymentFailed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: earthGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (bookingData['id'] != null)
                      Text(
                        'Booking ID: #${bookingData['id']}',
                        style: const TextStyle(
                          color: earthGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      )
                    else if (isValidated)
                      const Text(
                        'Validation Successful',
                        style: TextStyle(
                          color: earthGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    if (bookingData['id'] != null || isValidated)
                      const SizedBox(height: 8),
                    Text(
                      'TZS ${_formatAmount(bookingData['total_amount'] ?? _totalPrice)}',
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isValidated) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${bookingData['number_of_nights'] ?? _numberOfNights} night${(bookingData['number_of_nights'] ?? _numberOfNights) > 1 ? 's' : ''}',
                        style: const TextStyle(color: textLight, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (isPaymentFailed && transactionData != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Booking created but payment failed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Booking ID: #${bookingData?['id']}',
                      style: const TextStyle(color: textDark, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (isPaymentFailed)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigate back to booking page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: softCream,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Retry payment
                          if (bookingData?['id'] != null) {
                            Navigator.of(context).pop();
                            await _retryPayment(bookingData!['id']);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: earthGreen,
                          foregroundColor: softCream,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Retry Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? earthGreen : Colors.red,
                    foregroundColor: softCream,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isSuccess ? 'Done' : 'Try Again',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _retryPayment(int bookingId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: softCream,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: earthGreen),
              SizedBox(height: 20),
              Text(
                'Retrying payment...',
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final response = await BookingService.retryPayment(
        bookingId: bookingId,
        paymentMethod: _paymentMethod,
        paymentReference: _mobileNumberController.text,
      );

      Navigator.of(context).pop();
      _showBookingResultDialog(response);
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog('Failed to retry payment: $e');
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return _totalPrice.toStringAsFixed(0);
    if (amount is num) {
      return amount.toStringAsFixed(0);
    }
    return _totalPrice.toStringAsFixed(0);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: softCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Error', style: TextStyle(color: textDark)),
        content: Text(message, style: const TextStyle(color: textLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: earthGreen)),
          ),
        ],
      ),
    );
  }

  void _showValidationErrorsDialog(
    Map<String, dynamic> errors,
    String mainMessage,
  ) {
    // Build list of error messages
    List<String> errorMessages = [];
    errors.forEach((key, value) {
      if (value is List) {
        errorMessages.addAll(value.map((e) => e.toString()));
      } else {
        errorMessages.add(value.toString());
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: softCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Validation Error',
                style: TextStyle( 
                  color: textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainMessage,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...errorMessages.map(
                (error) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: earthGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: softCream, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmSand,
      appBar: SingleMGAppBar(
        'Book Room ${widget.room.roomnumber}',
        context: context,
        isTitleCentered: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconContainer(
              icon: Icons.share,
              backgroundColor: softCream,
              iconColor: richBrown,
              onTap: () {
                setState(() {});
              },
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Column(
                  children: [
                    // Room Card
                    _buildRoomCard(),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Booking Mode Selection
                          _buildSection(
                            title: 'How would you like to book?',
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildModeChip(
                                    'today',
                                    'Today',
                                    Icons.today,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModeChip(
                                    'pick_dates',
                                    'Pick Dates',
                                    Icons.calendar_month,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Date selection per mode
                          _buildDateSelectionForMode(),
                          const SizedBox(height: 20),

                          // Contact Number
                          _buildSection(
                            title: 'Ingiza Number ya Malipo',
                            child: Column(
                              children: [
                                _buildPaymentInfo(),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _bookerNumberController,
                                  hint: 'Ingiza namba ya simu ya malipo',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your contact number';
                                    }

                                    // Remove any spaces or special characters
                                    String cleanNumber = value.replaceAll(
                                      RegExp(r'[^\d+]'),
                                      '',
                                    );

                                    // Check if it starts with + and country code
                                    if (cleanNumber.startsWith('+')) {
                                      // For international format (+255...)
                                      if (cleanNumber.length < 12 ||
                                          cleanNumber.length > 13) {
                                        return 'Invalid phone number format';
                                      }
                                      if (!cleanNumber.startsWith('+255')) {
                                        return 'Please use Tanzania phone number (+255...)';
                                      }
                                    } else if (cleanNumber.startsWith('0')) {
                                      // For local format (0...)
                                      if (cleanNumber.length != 10) {
                                        return 'Phone number must be 10 digits (0XXXXXXXXX)';
                                      }
                                    } else if (cleanNumber.startsWith('255')) {
                                      // For format without + (255...)
                                      if (cleanNumber.length != 12) {
                                        return 'Invalid phone number format';
                                      }
                                    } else {
                                      return 'Phone number must start with 0, 255, or +255';
                                    }

                                    // Validate Tanzania mobile prefixes (after country code or 0)
                                    String prefix;
                                    if (cleanNumber.startsWith('+255')) {
                                      prefix = cleanNumber.substring(4, 6);
                                    } else if (cleanNumber.startsWith('255')) {
                                      prefix = cleanNumber.substring(3, 5);
                                    } else {
                                      prefix = cleanNumber.substring(1, 3);
                                    }

                                    List<String> validPrefixes = [
                                      '61',
                                      '62',
                                      '65',
                                      '67',
                                      '68',
                                      '69',
                                      '71',
                                      '72',
                                      '73',
                                      '74',
                                      '75',
                                      '76',
                                      '77',
                                      '78',
                                    ];
                                    if (!validPrefixes.contains(prefix)) {
                                      return 'Invalid Tanzania mobile number';
                                    }

                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Price Bar
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softCream,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Room Image
          SizedBox(
            width: 80,
            height: 80,
            child: Showimage.networkImage(imageUrl: widget.room.frontimage),
          ),
          const SizedBox(width: 16),
          // Room Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.roomnumber,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.room.roomtype,
                  style: const TextStyle(color: textLight, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'TZS ${widget.room.pricepernight.toStringAsFixed(0)}/night',
                  style: const TextStyle(
                    color: earthGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildModeChip(String value, String title, IconData icon) {
    final isSelected = _bookingMode == value;
    return InkWell(
      onTap: () {
        setState(() {
          _bookingMode = value;
          if (value == 'today') {
            _checkInDate = _today;
            _checkOutDate = _today.add(const Duration(days: 1));
          } else if (value == 'pick_dates') {
            _selectedDates.clear();
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? earthGreen : softCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? earthGreen : lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isSelected ? softCream : textDark),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? softCream : textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionForMode() {
    switch (_bookingMode) {
      case 'today':
        return _buildTodaySelection();
      case 'pick_dates':
        return _buildPickDatesSelection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTodaySelection() {
    return _buildSection(
      title: 'Book from today',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: softCream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: earthGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.today, size: 20, color: earthGreen),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-in',
                          style: TextStyle(color: textLight, fontSize: 12),
                        ),
                        Text(
                          'Today',
                          style: TextStyle(
                            color: textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectCheckOutDate(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: earthGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, size: 20, color: earthGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Until date',
                            style: TextStyle(color: textLight, fontSize: 12),
                          ),
                          Text(
                            '${_checkOutDate.day}/${_checkOutDate.month}/${_checkOutDate.year}',
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: textLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: earthGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nights',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$_numberOfNights night${_numberOfNights > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: earthGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickDatesSelection() {
    return _buildSection(
      title: 'Select dates (single, range, or skip dates)',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: softCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: lightGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: () => _showPickDatesCalendar(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add date'),
              style: OutlinedButton.styleFrom(
                foregroundColor: earthGreen,
                side: const BorderSide(color: earthGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_selectedDates.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedDates.map((d) {
                  return Chip(
                    label: Text(
                      '${d.day}/${d.month}/${d.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removePickDatesDate(d),
                    backgroundColor: earthGreen.withOpacity(0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedDates.length} night${_selectedDates.length > 1 ? 's' : ''} selected',
                style: TextStyle(
                  color: textLight,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: earthGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: earthGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: earthGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.phone_iphone, color: earthGreen, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Only The Following',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'M-Pesa, Tigo Pesa, Airtel Money',
                  style: TextStyle(color: textLight, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.phone
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textLight, fontSize: 14),
        prefixIcon: Icon(icon, color: textLight, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: earthGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: softCream,
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: validator,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softCream,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(color: textLight, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_totalPrice.toStringAsFixed(0)} TZS',
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$_numberOfNights night${_numberOfNights > 1 ? 's' : ''}',
                    style: const TextStyle(color: textLight, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 160,
              height: 56,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submitBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: earthGreen,
                  foregroundColor: softCream,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NonConsecutiveCalendarSheet extends StatefulWidget {
  final List<DateTime> selectedDates;
  final DateTime today;
  final DateTime lastDate;
  final void Function(List<DateTime>) onDone;

  const _NonConsecutiveCalendarSheet({
    required this.selectedDates,
    required this.today,
    required this.lastDate,
    required this.onDone,
  });

  @override
  State<_NonConsecutiveCalendarSheet> createState() =>
      _NonConsecutiveCalendarSheetState();
}

class _NonConsecutiveCalendarSheetState
    extends State<_NonConsecutiveCalendarSheet> {
  late List<DateTime> _selected;
  late DateTime _focusedMonth;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  bool _isSelected(DateTime day) =>
      _selected.any((d) => _isSameDay(d, day));

  bool _isSelectable(DateTime day) {
    final n = _normalize(day);
    return !n.isBefore(widget.today) && !n.isAfter(widget.lastDate);
  }

  DateTime _clampFocusedDay(DateTime value) {
    final first = DateTime(widget.today.year, widget.today.month, widget.today.day);
    final last = DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day);
    if (value.isBefore(first)) return first;
    if (value.isAfter(last)) return last;
    return value;
  }

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedDates);
    // Remove dates outside [today, lastDate] to avoid stale/past selections
    final todayNorm = _normalize(widget.today);
    final lastNorm = _normalize(widget.lastDate);
    _selected.removeWhere((d) => d.isBefore(todayNorm) || d.isAfter(lastNorm));
    _selected.sort((a, b) => a.compareTo(b));
    // focusedDay must be >= firstDay per TableCalendar assertion
    _focusedMonth = _selected.isNotEmpty
        ? _clampFocusedDay(DateTime(_selected.first.year, _selected.first.month, _selected.first.day))
        : DateTime(widget.today.year, widget.today.month, widget.today.day);
  }

  void _toggleDate(DateTime selectedDay, DateTime focusedDay) {
    final n = _normalize(selectedDay);
    if (!_isSelectable(selectedDay)) return;
    setState(() {
      if (_isSelected(n)) {
        _selected.removeWhere((d) => _isSameDay(d, n));
      } else {
        _selected.add(n);
        _selected.sort((a, b) => a.compareTo(b));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: softCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: richBrown.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select dates',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_selected.length} selected',
                  style: TextStyle(
                    color: earthGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: TableCalendar(
                firstDay: widget.today,
                lastDay: widget.lastDate,
                focusedDay: _focusedMonth,
                selectedDayPredicate: (day) => _isSelected(day),
                onDaySelected: _toggleDate,
                onPageChanged: (focused) =>
                    setState(() => _focusedMonth = _clampFocusedDay(focused)),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: textDark),
                  rightChevronIcon: Icon(Icons.chevron_right, color: textDark),
                  titleTextStyle: TextStyle(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: earthGreen,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: earthGreen.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: softCream,
                    fontWeight: FontWeight.w700,
                  ),
                  outsideTextStyle: TextStyle(
                    color: textLight.withOpacity(0.5),
                  ),
                  defaultTextStyle: const TextStyle(color: textDark),
                  weekendTextStyle: const TextStyle(color: textDark),
                  disabledTextStyle: TextStyle(
                    color: textLight.withOpacity(0.5),
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (!_isSelected(date)) return null;
                    return Positioned(
                      bottom: 2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: earthGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDone(_selected);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: earthGreen,
                  foregroundColor: softCream,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
