class MessageModel {
  final int id;
  final int chatId;
  final String senderType;
  final int senderId;
  final String message;
  final int readStatus;
  final String? createdAt;
  final SenderInfo? sender;
  final List<MessageAttachment> attachments;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderType,
    required this.senderId,
    required this.message,
    required this.readStatus,
    this.createdAt,
    this.sender,
    required this.attachments,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle read_status as either string ("unread"/"read") or int (0/1)
    int readStatusValue = 0;
    final readStatusData = json['read_status'];
    if (readStatusData is String) {
      readStatusValue = readStatusData == 'read' ? 1 : 0;
    } else if (readStatusData is int) {
      readStatusValue = readStatusData;
    } else if (readStatusData is bool) {
      readStatusValue = readStatusData ? 1 : 0;
    }

    return MessageModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id'].toString()) ?? 0),
      chatId: json['chat_id'] is int
          ? json['chat_id']
          : (int.tryParse(json['chat_id'].toString()) ?? 0),
      senderType: json['sender_type']?.toString() ?? 'customer',
      senderId: json['sender_id'] is int
          ? json['sender_id']
          : (int.tryParse(json['sender_id'].toString()) ?? 0),
      message: json['message']?.toString() ?? '',
      readStatus: readStatusValue,
      createdAt: json['created_at']?.toString(),
      sender: json['sender'] != null
          ? SenderInfo.fromJson(json['sender'])
          : null,
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((attachment) => MessageAttachment.fromJson(attachment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_type': senderType,
      'sender_id': senderId,
      'message': message,
      'read_status': readStatus,
      'created_at': createdAt,
      'sender': sender?.toJson(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  bool get isRead => readStatus == 1;
  bool get isFromCustomer => senderType == 'customer';
}

class SenderInfo {
  final int id;
  final String username;
  final String? userimage;

  SenderInfo({required this.id, required this.username, this.userimage});

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Unknown',
      userimage: json['userimage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'userimage': userimage};
  }
}

class MessageAttachment {
  final int id;
  final String filePath;
  final String? fileType;
  final String? uploadedAt;

  MessageAttachment({
    required this.id,
    required this.filePath,
    this.fileType,
    this.uploadedAt,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] ?? 0,
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'],
      uploadedAt: json['uploaded_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_path': filePath,
      'file_type': fileType,
      'uploaded_at': uploadedAt,
    };
  }
}
