import 'package:bnbfrontendflutter/bnb/bnbchatting/messagechat.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final motel = booking.motel;
    final room = booking.room;

    return InkWell(
      onTap: () {
        NavigationUtil.pushwithslideTo(
          context,
          MessageChat(
            bookingId: booking.id,
            motelId: motel.id,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: earthGreen.withOpacity(0.2)),
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: earthGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.hotel, color: earthGreen, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    motel.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${room.roomType} - ${room.roomNumber}",
                    style: TextStyle(
                      fontSize: 14,
                      color: textDark.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "District: ${motel.district}",
                    style: TextStyle(
                      fontSize: 13,
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
}

class BookingModel {
  final int id;
  final String bookingReference;
  final String status;
  final String? checkInDate;
  final String? checkOutDate;
  final String? totalAmount;
  final String createdAt;
  final RoomModel room;
  final MotelModel motel;
  final List<TransactionModel> transactions;

  BookingModel({
    required this.id,
    required this.bookingReference,
    required this.status,
    this.checkInDate,
    this.checkOutDate,
    this.totalAmount,
    required this.createdAt,
    required this.room,
    required this.motel,
    required this.transactions,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      bookingReference: json['booking_reference'] ?? '',
      status: json['status'] ?? '',
      checkInDate: json['check_in_date'],
      checkOutDate: json['check_out_date'],
      totalAmount: json['total_amount']?.toString(),
      createdAt: json['created_at'] ?? '',
      room: RoomModel.fromJson(json['room'] ?? {}),
      motel: MotelModel.fromJson(json['motel'] ?? {}),
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  // Optional computed flags (for UI use)
  bool get isPast {
    if (checkOutDate == null) return false;
    try {
      return DateTime.parse(checkOutDate!).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  bool get isUpcoming {
    if (checkInDate == null) return false;
    try {
      return DateTime.parse(checkInDate!).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  bool get isCurrent {
    if (checkInDate == null || checkOutDate == null) return false;
    try {
      final now = DateTime.now();
      final checkIn = DateTime.parse(checkInDate!);
      final checkOut = DateTime.parse(checkOutDate!);
      return now.isAfter(checkIn) && now.isBefore(checkOut);
    } catch (_) {
      return false;
    }
  }
}

class RoomModel {
  final int id;
  final String roomNumber;
  final String roomType;
  final String pricePerNight;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerNight,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      roomType: json['room_type'] ?? '',
      pricePerNight: json['price_per_night']?.toString() ?? '0.00',
    );
  }
}

class MotelModel {
  final int id;
  final String name;
  final String address;
  final String district;

  MotelModel({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
  });

  factory MotelModel.fromJson(Map<String, dynamic> json) {
    return MotelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      district: json['district'] ?? '',
    );
  }
}

class TransactionModel {
  final int? id;
  final String? amount;
  final String? status;
  final String? createdAt;

  TransactionModel({this.id, this.amount, this.status, this.createdAt});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount']?.toString(),
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
