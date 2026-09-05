import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

class BusinessModel {
  final String id;
  final String name;
  final String address;
  final String description;
  final String bgImg;
  final String profilImg;
  final double rating;
  final int reviewCount;
  final Map<String, String> openingHours;
  final BusinessType type;
  final String phone;
  final String? email;
  final String? website;
  final List<String> images;
  final Map<String, dynamic> specificData;
  final List<BusinessReview> reviews;
  final bool isFavorite;
  final double? latitude;
  final double? longitude;
  final List<BusinessModel>? stores;
  final bool isSponsored;
  final DateTime createdAt;
  final bool isPaused;
  final String? pauseNote;
  final String? province;
  final String? ville;
  final String? commune;
  final String? quartier;
  final String? avenue;
  final String? numero;

  BusinessModel({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.bgImg,
    required this.profilImg,
    required this.rating,
    required this.reviewCount,
    required this.openingHours,
    required this.type,
    required this.phone,
    this.email,
    this.website,
    required this.images,
    required this.specificData,
    required this.reviews,
    required this.isFavorite,
    this.latitude,
    this.longitude,
    this.stores,
    required this.isSponsored,
    required this.createdAt,
    this.isPaused = false,
    this.pauseNote,
    this.province,
    this.ville,
    this.commune,
    this.quartier,
    this.avenue,
    this.numero,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      bgImg: json['bg_img'] ?? json['bgImg'] ?? '',
      profilImg: json['profil_img'] ?? json['profilImg'] ?? '',
      rating: json['rating'] is String
          ? double.tryParse(json['rating']) ?? 0.0
          : (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      openingHours: Map<String, String>.from(json['opening_hours'] ?? {}),
      type: BusinessType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BusinessType.other,
      ),
      phone: json['phone'] ?? '',
      email: json['email'],
      website: json['website'],
      images: List<String>.from(json['images'] ?? []),
      specificData: Map<String, dynamic>.from(json['specific_data'] ?? {}),
      reviews:
          (json['reviews'] as List?)
              ?.map((r) => BusinessReview.fromJson(r))
              .toList() ??
          [],
      isFavorite: json['is_favorite'] ?? json['isFavorite'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      stores: json['stores'] != null
          ? (json['stores'] as List)
                .map((s) => BusinessModel.fromJson(s))
                .toList()
          : null,
      isSponsored: json['is_sponsored'] ?? json['isSponsored'] ?? false,
      isPaused: json['is_paused'] ?? json['isPaused'] ?? false,
      pauseNote: json['pause_note']?.toString(),
      province: json['province']?.toString(),
      ville: json['ville']?.toString(),
      commune: json['commune']?.toString(),
      quartier: json['quartier']?.toString(),
      avenue: json['avenue']?.toString(),
      numero: json['numero']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'bg_img': bgImg,
      'profil_img': profilImg,
      'rating': rating,
      'review_count': reviewCount,
      'opening_hours': openingHours,
      'type': type.name,
      'phone': phone,
      'email': email,
      'website': website,
      'images': images,
      'specific_data': specificData,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'is_favorite': isFavorite,
      'latitude': latitude,
      'longitude': longitude,
      'stores': stores?.map((store) => store.toJson()).toList(),
      'is_sponsored': isSponsored,
      'created_at': createdAt.toIso8601String(),
      'is_paused': isPaused,
      'pause_note': pauseNote,
      'province': province,
      'ville': ville,
      'commune': commune,
      'quartier': quartier,
      'avenue': avenue,
      'numero': numero,
    };
  }

  Business toEntity() {
    return Business(
      id: id,
      name: name,
      address: address,
      description: description,
      bgImg: bgImg,
      profilImg: profilImg,
      rating: rating,
      reviewCount: reviewCount,
      openingHours: openingHours,
      type: type,
      phone: phone,
      email: email,
      website: website,
      images: images,
      specificData: specificData,
      reviews: reviews,
      isFavorite: isFavorite,
      latitude: latitude,
      longitude: longitude,
      stores: stores?.map((store) => store.toEntity()).toList(),
      isSponsored: isSponsored,
      createdAt: createdAt,
      isPaused: isPaused,
      pauseNote: pauseNote,
      province: province,
      ville: ville,
      commune: commune,
      quartier: quartier,
      avenue: avenue,
      numero: numero,
    );
  }
}
