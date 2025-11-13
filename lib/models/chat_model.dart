class ChatModel {
  final int id;
  final int motelId;
  final int? bookingId;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final MotelInfo motel;
  final LastMessage? lastMessage;

  ChatModel({
    required this.id,
    required this.motelId,
    this.bookingId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.motel,
    this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? 0,
      motelId: json['motel_id'] ?? 0,
      bookingId: json['booking_id'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      motel: MotelInfo.fromJson(json['motel'] ?? {}),
      lastMessage: json['last_message'] != null
          ? LastMessage.fromJson(json['last_message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motel_id': motelId,
      'booking_id': bookingId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'motel': motel.toJson(),
      'last_message': lastMessage?.toJson(),
    };
  }
}

class MotelInfo {
  final int id;
  final String name;
  final String? frontImage;
  final String? streetAddress;

  MotelInfo({
    required this.id,
    required this.name,
    this.frontImage,
    this.streetAddress,
  });

  factory MotelInfo.fromJson(Map<String, dynamic> json) {
    return MotelInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Motel',
      frontImage: json['front_image'],
      streetAddress: json['street_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'front_image': frontImage,
      'street_address': streetAddress,
    };
  }
}

class LastMessage {
  final int id;
  final String message;
  final String senderType;
  final String? createdAt;

  LastMessage({
    required this.id,
    required this.message,
    required this.senderType,
    this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      senderType: json['sender_type'] ?? 'customer',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender_type': senderType,
      'created_at': createdAt,
    };
  }
}
