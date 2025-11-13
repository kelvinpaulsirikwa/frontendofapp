class BookingModel {
  final int id;
  final int customerId;
  final int roomId;
  final String checkInDate;
  final String checkOutDate;
  final int numberOfNights;
  final double pricePerNight;
  final double totalAmount;
  final String contactNumber;
  final String status;
  final String? specialRequests;
  final String createdAt;
  final String bookingReference;
  final RoomInfo room;
  final MotelInfo motel;
  final List<TransactionInfo> transactions;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.pricePerNight,
    required this.totalAmount,
    required this.contactNumber,
    required this.status,
    this.specialRequests,
    required this.createdAt,
    required this.bookingReference,
    required this.room,
    required this.motel,
    required this.transactions,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      numberOfNights: json['number_of_nights'] ?? 0,
      pricePerNight: _parseToDouble(json['price_per_night']),
      totalAmount: _parseToDouble(json['total_amount']),
      contactNumber: json['contact_number'] ?? '',
      status: json['status'] ?? 'pending',
      specialRequests: json['special_requests'],
      createdAt: json['created_at'] ?? '',
      bookingReference: json['booking_reference'] ?? 'BK${json['id'] ?? 0}',
      room: RoomInfo.fromJson(json['room'] ?? {}),
      motel: MotelInfo.fromJson(json['motel'] ?? {}),
      transactions: (json['transactions'] as List<dynamic>? ?? [])
          .map((transaction) => TransactionInfo.fromJson(transaction))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'room_id': roomId,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'number_of_nights': numberOfNights,
      'price_per_night': pricePerNight,
      'total_amount': totalAmount,
      'contact_number': contactNumber,
      'status': status,
      'special_requests': specialRequests,
      'created_at': createdAt,
      'booking_reference': bookingReference,
      'room': room.toJson(),
      'motel': motel.toJson(),
      'transactions': transactions
          .map((transaction) => transaction.toJson())
          .toList(),
    };
  }

  bool get isUpcoming {
    final checkIn = DateTime.tryParse(checkInDate);
    if (checkIn == null) return false;
    return checkIn.isAfter(DateTime.now());
  }

  bool get isPast {
    final checkOut = DateTime.tryParse(checkOutDate);
    if (checkOut == null) return false;
    return checkOut.isBefore(DateTime.now());
  }

  bool get isCurrent {
    final checkIn = DateTime.tryParse(checkInDate);
    final checkOut = DateTime.tryParse(checkOutDate);
    if (checkIn == null || checkOut == null) return false;
    final now = DateTime.now();
    return now.isAfter(checkIn) && now.isBefore(checkOut);
  }
}

class RoomInfo {
  final int id;
  final String roomNumber;
  final String roomType;
  final double pricePerNight;

  RoomInfo({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerNight,
  });

  factory RoomInfo.fromJson(Map<String, dynamic> json) {
    return RoomInfo(
      id: json['id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      roomType: json['room_type'] ?? '',
      pricePerNight: _parseToDouble(json['price_per_night']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': roomNumber,
      'room_type': roomType,
      'price_per_night': pricePerNight,
    };
  }
}

class MotelInfo {
  final int id;
  final String name;
  final String address;
  final String district;

  MotelInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
  });

  factory MotelInfo.fromJson(Map<String, dynamic> json) {
    return MotelInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address, 'district': district};
  }
}

class TransactionInfo {
  final int id;
  final String transactionId;
  final double amount;
  final String paymentMethod;
  final String? paymentReference;
  final String status;
  final String? processedAt;
  final String? createdAt;
  final TransactionBookingSummary? booking;

  TransactionInfo({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    this.paymentReference,
    required this.status,
    this.processedAt,
    this.createdAt,
    this.booking,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      amount: _parseToDouble(json['amount']),
      paymentMethod: json['payment_method'] ?? '',
      paymentReference: json['payment_reference'],
      status: json['status'] ?? 'pending',
      processedAt: json['processed_at'],
      createdAt: json['created_at'],
      booking: json['booking'] != null
          ? TransactionBookingSummary.fromJson(
              Map<String, dynamic>.from(json['booking']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'status': status,
      'processed_at': processedAt,
      'created_at': createdAt,
      'booking': booking?.toJson(),
    };
  }

  String get paymentMethodDisplay {
    switch (paymentMethod) {
      case 'mobile':
        return 'Mobile';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'card':
        return 'Bank Card';
      case 'cash':
        return 'Cash';
      case 'mobile_money':
        return 'Mobile Money';
      default:
        return paymentMethod;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
}

class TransactionBookingSummary {
  final int id;
  final String bookingReference;
  final String status;
  final String? checkInDate;
  final String? checkOutDate;
  final int numberOfNights;
  final double totalAmount;
  final TransactionBookingCustomer? customer;
  final TransactionBookingRoom? room;
  final TransactionBookingMotel? motel;

  TransactionBookingSummary({
    required this.id,
    required this.bookingReference,
    required this.status,
    this.checkInDate,
    this.checkOutDate,
    required this.numberOfNights,
    required this.totalAmount,
    this.customer,
    this.room,
    this.motel,
  });

  factory TransactionBookingSummary.fromJson(Map<String, dynamic> json) {
    return TransactionBookingSummary(
      id: json['id'] ?? 0,
      bookingReference: json['booking_reference'] ?? '',
      status: json['status'] ?? '',
      checkInDate: json['check_in_date'],
      checkOutDate: json['check_out_date'],
      numberOfNights: json['number_of_nights'] ?? 0,
      totalAmount: _parseToDouble(json['total_amount']),
      customer: json['customer'] != null
          ? TransactionBookingCustomer.fromJson(
              Map<String, dynamic>.from(json['customer']),
            )
          : null,
      room: json['room'] != null
          ? TransactionBookingRoom.fromJson(
              Map<String, dynamic>.from(json['room']),
            )
          : null,
      motel: json['motel'] != null
          ? TransactionBookingMotel.fromJson(
              Map<String, dynamic>.from(json['motel']),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'status': status,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'number_of_nights': numberOfNights,
      'total_amount': totalAmount,
      'customer': customer?.toJson(),
      'room': room?.toJson(),
      'motel': motel?.toJson(),
    };
  }
}

class TransactionBookingCustomer {
  final int id;
  final String username;
  final String email;
  final String? imageUrl;
  final String? phoneNumber;

  TransactionBookingCustomer({
    required this.id,
    required this.username,
    required this.email,
    this.imageUrl,
    this.phoneNumber,
  });

  factory TransactionBookingCustomer.fromJson(Map<String, dynamic> json) {
    return TransactionBookingCustomer(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['useremail'] ?? '',
      imageUrl: json['userimage'],
      phoneNumber: json['phonenumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'useremail': email,
      'userimage': imageUrl,
      'phonenumber': phoneNumber,
    };
  }
}

class TransactionBookingRoom {
  final int id;
  final String roomNumber;
  final String roomType;
  final double pricePerNight;

  TransactionBookingRoom({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerNight,
  });

  factory TransactionBookingRoom.fromJson(Map<String, dynamic> json) {
    return TransactionBookingRoom(
      id: json['id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      roomType: json['room_type'] ?? '',
      pricePerNight: _parseToDouble(json['price_per_night']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': roomNumber,
      'room_type': roomType,
      'price_per_night': pricePerNight,
    };
  }
}

class TransactionBookingMotel {
  final int id;
  final String name;
  final String address;
  final String district;

  TransactionBookingMotel({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
  });

  factory TransactionBookingMotel.fromJson(Map<String, dynamic> json) {
    return TransactionBookingMotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address, 'district': district};
  }
}

class TransactionModel {
  final int id;
  final int bookingId;
  final String transactionId;
  final double amount;
  final String paymentMethod;
  final String? paymentReference;
  final String status;
  final String processedAt;

  TransactionModel({
    required this.id,
    required this.bookingId,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    this.paymentReference,
    required this.status,
    required this.processedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      amount: _parseToDouble(json['amount']),
      paymentMethod: json['payment_method'] ?? '',
      paymentReference: json['payment_reference'],
      status: json['status'] ?? 'pending',
      processedAt: json['processed_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'transaction_id': transactionId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'status': status,
      'processed_at': processedAt,
    };
  }
}

double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return 0.0;
}
