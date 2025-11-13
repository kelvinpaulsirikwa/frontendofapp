class AboutBnBModel {
  final int totalMotels;
  final int totalAmenities;
  final int totalRegions;
  final int totalDistricts;
  final int totalCountries;
  final List<FeaturedAmenity> featuredAmenities;
  final List<RegionInfo> regions;
  final List<CountryInfo> countries;

  AboutBnBModel({
    required this.totalMotels,
    required this.totalAmenities,
    required this.totalRegions,
    required this.totalDistricts,
    required this.totalCountries,
    required this.featuredAmenities,
    required this.regions,
    required this.countries,
  });

  factory AboutBnBModel.fromJson(Map<String, dynamic> json) {
    return AboutBnBModel(
      totalMotels: json['total_motels'] ?? 0,
      totalAmenities: json['total_amenities'] ?? 0,
      totalRegions: json['total_regions'] ?? 0,
      totalDistricts: json['total_districts'] ?? 0,
      totalCountries: json['total_countries'] ?? 0,
      featuredAmenities:
          (json['featured_amenities'] as List<dynamic>?)
              ?.map((item) => FeaturedAmenity.fromJson(item))
              .toList() ??
          [],
      regions:
          (json['regions'] as List<dynamic>?)
              ?.map((item) => RegionInfo.fromJson(item))
              .toList() ??
          [],
      countries:
          (json['countries'] as List<dynamic>?)
              ?.map((item) => CountryInfo.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class FeaturedAmenity {
  final int id;
  final String name;
  final String? icon;
  final int usageCount;

  FeaturedAmenity({
    required this.id,
    required this.name,
    this.icon,
    required this.usageCount,
  });

  factory FeaturedAmenity.fromJson(Map<String, dynamic> json) {
    return FeaturedAmenity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      usageCount: json['usage_count'] ?? 0,
    );
  }
}

class RegionInfo {
  final int id;
  final String name;
  final String country;
  final int totalDistricts;
  final int totalMotels;

  RegionInfo({
    required this.id,
    required this.name,
    required this.country,
    required this.totalDistricts,
    required this.totalMotels,
  });

  factory RegionInfo.fromJson(Map<String, dynamic> json) {
    return RegionInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      totalDistricts: json['total_districts'] ?? 0,
      totalMotels: json['total_motels'] ?? 0,
    );
  }
}

class CountryInfo {
  final int id;
  final String name;
  final int totalRegions;

  CountryInfo({
    required this.id,
    required this.name,
    required this.totalRegions,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      totalRegions: json['total_regions'] ?? 0,
    );
  }
}

class AmenityModel {
  final int id;
  final String name;
  final String? icon;
  final String description;
  final int usageCount;

  AmenityModel({
    required this.id,
    required this.name,
    this.icon,
    required this.description,
    required this.usageCount,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      description: json['description'] ?? '',
      usageCount: json['usage_count'] ?? 0,
    );
  }
}
