import 'package:hive/hive.dart';

part 'bnbmodel.g.dart'; // Required for code generation

@HiveType(typeId: 0) // Unique typeId for Hive
class SimpleMotel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? frontImage;

  @HiveField(3)
  final String streetAddress;

  @HiveField(4)
  final String motelType;

  @HiveField(5)
  final String district;

  @HiveField(6)
  final double? longitude;

  @HiveField(7)
  final double? latitude;

    SimpleMotel({
    required this.id,
    required this.name,
    this.frontImage,
    required this.streetAddress,
    required this.motelType,
    required this.district,
    this.longitude,
    this.latitude,
  });

  factory SimpleMotel.fromJson(Map<String, dynamic> json) {
    return SimpleMotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Motel',
      frontImage: json['front_image'],
      streetAddress: json['street_address'] ?? 'Unknown Street',
      motelType: json['motel_type'] ?? 'Unknown Type',
      district: json['district'] ?? 'Unknown District',
      longitude: (json['longitude'] != null)
          ? double.tryParse(json['longitude'].toString())
          : null,
      latitude: (json['latitude'] != null)
          ? double.tryParse(json['latitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'front_image': frontImage,
      'street_address': streetAddress,
      'motel_type': motelType,
      'district': district,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  @override
  String toString() {
    return 'SimpleMotel(id: $id, name: $name, frontImage: $frontImage, streetAddress: $streetAddress, motelType: $motelType, district: $district, longitude: $longitude, latitude: $latitude)';
  }
}
