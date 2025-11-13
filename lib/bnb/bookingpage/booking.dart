import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/models/bnbroommodel.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/services/booking_service.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  String _bookingDuration = 'one_day';
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  final String _paymentMethod = 'mobile_money';

  int get _numberOfNights {
    return _checkOutDate.difference(_checkInDate).inDays;
  }

  double get _totalPrice {
    return widget.room.pricepernight * _numberOfNights;
  }

  @override
  void dispose() {
    _bookerNumberController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
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
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        // Ensure check-out is always after check-in
        if (_checkOutDate.isBefore(_checkInDate.add(const Duration(days: 1)))) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
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
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
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
        final response = await BookingService.createBookingAndProcessPayment(
          roomId: widget.room.id,
          customerId: 1, // TODO: Get from user auth
          checkInDate: _checkInDate.toIso8601String().split('T')[0],
          checkOutDate: _checkOutDate.toIso8601String().split('T')[0],
          contactNumber: _bookerNumberController.text,
          paymentMethod: _paymentMethod,
          paymentReference: _mobileNumberController.text,
          specialRequests: null,
        );

        Navigator.of(context).pop();

        // Check if response has errors (validation errors)
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
                          // Duration Selection - HORIZONTAL
                          _buildSection(
                            title: 'Stay Duration',
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildDurationOption(
                                    value: 'one_day',
                                    title: 'One Night',
                                    icon: Icons.nightlight_round,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDurationOption(
                                    value: 'multiple_days',
                                    title: 'Many Nights',
                                    icon: Icons.calendar_month,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Dates Selection
                          if (_bookingDuration == 'multiple_days') ...[
                            _buildSection(
                              title: 'Select Dates',
                              child: _buildDateSelection(),
                            ),
                            const SizedBox(height: 20),
                          ],

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

  Widget _buildDurationOption({
    required String value,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _bookingDuration == value;
    return InkWell(
      onTap: () {
        setState(() {
          _bookingDuration = value;
          if (value == 'one_day') {
            _checkOutDate = _checkInDate.add(const Duration(days: 1));
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? softCream : textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Check-in Date Picker
          InkWell(
            onTap: () => _selectCheckInDate(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: textLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check-in Date',
                          style: TextStyle(color: textLight, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_checkInDate.day}/${_checkInDate.month}/${_checkInDate.year}',
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: textLight,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Check-out Date Picker
          InkWell(
            onTap: () => _selectCheckOutDate(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.logout, size: 20, color: earthGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check-out Date',
                          style: TextStyle(color: textLight, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_checkOutDate.day}/${_checkOutDate.month}/${_checkOutDate.year}',
                          style: const TextStyle(
                            color: earthGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: textLight,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nights Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: earthGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.nights_stay, size: 20, color: earthGreen),
                    const SizedBox(width: 8),
                    const Text(
                      'Number of Nights',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                onPressed: _submitBooking,
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
