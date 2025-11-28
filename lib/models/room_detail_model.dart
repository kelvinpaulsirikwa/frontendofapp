class RoomImageModel {
  final int id;
  final int roomId;
  final String imageUrl;
  final String? description;
  final DateTime? createdAt;

  const RoomImageModel({
    required this.id,
    required this.roomId,
    required this.imageUrl,
    this.description,
    this.createdAt,
  });

  factory RoomImageModel.fromJson(Map<String, dynamic> json) {
    return RoomImageModel(
      id: json['id'] ?? 0,
      roomId: json['bnbroomid'] ?? 0,
      imageUrl: json['imagepath'] ?? json['filepath'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bnbroomid': roomId,
      'imagepath': imageUrl,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class RoomItemModel {
  final int id;
  final int roomId;
  final String name;
  final String? description;
  final DateTime? createdAt;

  const RoomItemModel({
    required this.id,
    required this.roomId,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory RoomItemModel.fromJson(Map<String, dynamic> json) {
    return RoomItemModel(
      id: json['id'] ?? 0,
      roomId: json['bnbroomid'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bnbroomid': roomId,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
