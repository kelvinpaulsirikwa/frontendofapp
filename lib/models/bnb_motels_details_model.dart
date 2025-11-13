class BnbMotelsDetailsModel {
  final int id;
  final String name;
  final String? frontImage;
  final String streetAddress;
  final String motelType;
  final String district;
  final double? longitude;
  final double? latitude;
  final String? contactPhone;
  final String? contactEmail;
  final int? totalRooms;
  final int? availableRooms;
  final String? description;
  final String? ownerName;
  final String? ownerEmail;
  final List<BnbImageModel> images;
  final List<BnbAmenityModel> amenities;

  BnbMotelsDetailsModel({
    required this.id,
    required this.name,
    this.frontImage,
    required this.streetAddress,
    required this.motelType,
    required this.district,
    this.longitude,
    this.latitude,
    this.contactPhone,
    this.contactEmail,
    this.totalRooms,
    this.availableRooms,
    this.description,
    this.ownerName,
    this.ownerEmail,
    required this.images,
    required this.amenities,
  });

  factory BnbMotelsDetailsModel.fromJson(Map<String, dynamic> json) {
    return BnbMotelsDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Motel',
      frontImage: json['front_image'],
      streetAddress: json['street_address'] ?? 'Unknown Street',
      motelType: json['motel_type']?['name'] ?? 'Unknown Type',
      district: json['district']?['name'] ?? 'Unknown District',
      longitude: (json['longitude'] != null)
          ? double.tryParse(json['longitude'].toString())
          : null,
      latitude: (json['latitude'] != null)
          ? double.tryParse(json['latitude'].toString())
          : null,
      contactPhone:
          json['details']?['contact_phone'] ?? json['owner']?['telephone'],
      contactEmail:
          json['details']?['contact_email'] ?? json['owner']?['useremail'],
      totalRooms: json['details']?['total_rooms'] ?? 4, // Default value
      availableRooms: json['details']?['available_rooms'] ?? 2, // Default value
      description: json['description'] ?? json['details']?['description'],
      ownerName: json['owner']?['username'] ?? json['owner']?['name'],
      ownerEmail: json['owner']?['useremail'] ?? json['owner']?['email'],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((image) => BnbImageModel.fromJson(image))
              .toList() ??
          [],
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((amenity) => BnbAmenityModel.fromJson(amenity))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'front_image': frontImage,
      'street_address': streetAddress,
      'motel_type': {'name': motelType},
      'district': {'name': district},
      'longitude': longitude,
      'latitude': latitude,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'total_rooms': totalRooms,
      'available_rooms': availableRooms,
      'description': description,
      'owner_name': ownerName,
      'owner_email': ownerEmail,
      'images': images.map((image) => image.toJson()).toList(),
      'amenities': amenities.map((amenity) => amenity.toJson()).toList(),
    };
  }
}

class BnbImageModel {
  final int id;
  final int motelId;
  final String imageUrl;
  final String? description;
  final DateTime? createdAt;

  BnbImageModel({
    required this.id,
    required this.motelId,
    required this.imageUrl,
    this.description,
    this.createdAt,
  });

  factory BnbImageModel.fromJson(Map<String, dynamic> json) {
    return BnbImageModel(
      id: json['id'] ?? 0,
      motelId: json['bnb_motels_id'] ?? 0,
      imageUrl: json['filepath'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bnb_motels_id': motelId,
      'filepath': imageUrl,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class BnbAmenityModel {
  final int id;
  final int motelId;
  final String name;
  final String? description;
  final String? icon;
  final String? iconPath; // Path to the icon image
  final DateTime? createdAt;

  BnbAmenityModel({
    required this.id,
    required this.motelId,
    required this.name,
    this.description,
    this.icon,
    this.iconPath,
    this.createdAt,
  });

  factory BnbAmenityModel.fromJson(Map<String, dynamic> json) {
    return BnbAmenityModel(
      id: json['id'] ?? 0,
      motelId: json['bnb_motels_id'] ?? 0,
      name: json['amenity']?['name'] ?? '',
      description: json['description'],
      icon: json['amenity']?['icon'],
      iconPath:
          json['amenity']?['icon'], // The icon field contains the image path
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bnb_motels_id': motelId,
      'amenity': {'name': name, 'icon': icon, 'iconPath': iconPath},
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class BnbAmenityImageModel {
  final int id;
  final int amenityId;
  final String imageUrl;
  final String? description;
  final DateTime? createdAt;

  BnbAmenityImageModel({
    required this.id,
    required this.amenityId,
    required this.imageUrl,
    this.description,
    this.createdAt,
  });

  factory BnbAmenityImageModel.fromJson(Map<String, dynamic> json) {
    return BnbAmenityImageModel(
      id: json['id'] ?? 0,
      amenityId: json['bnb_amenities_id'] ?? 0,
      imageUrl: json['filepath'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bnb_amenities_id': amenityId,
      'filepath': imageUrl,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
