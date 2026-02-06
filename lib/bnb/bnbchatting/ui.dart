import 'package:bnbfrontendflutter/bnb/bnbchatting/messagechat.dart';
import 'package:bnbfrontendflutter/utility/images.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final motel = booking.motel;
    final room = booking.room;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            NavigationUtil.pushwithslideTo(
              context,
              MessageChat(booking: booking),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Hotel Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: motel.frontImage != null && motel.frontImage!.isNotEmpty
                        ? Showimage.networkImage(imageUrl: motel.frontImage!)
                        : Container(
                            color: earthGreen.withOpacity(0.1),
                            child: const Icon(Icons.hotel, size: 32, color: earthGreen),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Right: Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motel.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${motel.address}, ${motel.district}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Room ${room.roomNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: earthGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              room.roomType,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: earthGreen,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: earthGreen, width: 1.5),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Chat',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: earthGreen,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 12,
                                  color: earthGreen,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
  final String? frontImage;

  MotelModel({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    this.frontImage,
  });

  factory MotelModel.fromJson(Map<String, dynamic> json) {
    return MotelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? json['street_address'] ?? '',
      district: json['district'] ?? '',
      frontImage: (json['front_image'] ?? json['image'])?.toString(),
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
