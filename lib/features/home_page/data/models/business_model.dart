import 'package:baobabe_0_2/features/home_page/domain/entities/business_entity.dart';

class BusinessModel {
  final String id;
  final String name;
  final String address;
  final String description;
  final String bgImg;
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

  BusinessModel({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.bgImg,
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
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      bgImg: json['bgImg'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      openingHours: Map<String, String>.from(json['openingHours'] as Map),
      type: _parseBusinessType(json['type'] as String),
      phone: json['phone'] as String,
      email: json['email'] as String?,
      website: json['website'] as String?,
      images: List<String>.from(json['images'] as List),
      specificData: Map<String, dynamic>.from(json['specificData'] as Map),
      reviews: (json['reviews'] as List).map((review) => BusinessReview(
        id: review['id'] as String,
        userName: review['userName'] as String,
        userAvatar: review['userAvatar'] as String,
        rating: (review['rating'] as num).toDouble(),
        comment: review['comment'] as String,
        date: DateTime.parse(review['date'] as String),
        likes: review['likes'] as int,
        commentCount: review['commentCount'] as int? ?? 0,
      )).toList(),
      isFavorite: json['isFavorite'] as bool,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      stores: json['stores'] != null
          ? (json['stores'] as List)
          .map((store) => BusinessModel.fromJson(store))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'bgImg': bgImg,
      'rating': rating,
      'reviewCount': reviewCount,
      'openingHours': openingHours,
      'type': _businessTypeToString(type),
      'phone': phone,
      'email': email,
      'website': website,
      'images': images,
      'specificData': specificData,
      'reviews': reviews.map((review) => {
        'id': review.id,
        'userName': review.userName,
        'userAvatar': review.userAvatar,
        'rating': review.rating,
        'comment': review.comment,
        'date': review.date.toIso8601String(),
        'likes': review.likes,
        'commentCount': review.commentCount,
      }).toList(),
      'isFavorite': isFavorite,
      'latitude': latitude,
      'longitude': longitude,
      'stores': stores?.map((store) => store.toJson()).toList(),
    };
  }

  Business toEntity() {
    return Business(
      id: id,
      name: name,
      address: address,
      description: description,
      bgImg: bgImg,
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
    );
  }

  static BusinessModel fromEntity(Business entity) {
    return BusinessModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      description: entity.description,
      bgImg: entity.bgImg,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      openingHours: entity.openingHours,
      type: entity.type,
      phone: entity.phone,
      email: entity.email,
      website: entity.website,
      images: entity.images,
      specificData: entity.specificData,
      reviews: entity.reviews,
      isFavorite: entity.isFavorite,
      latitude: entity.latitude,
      longitude: entity.longitude,
      stores: entity.stores != null
          ? entity.stores!
          .map((store) => BusinessModel.fromEntity(store))
          .toList()
          : null,
    );
  }

  static BusinessType _parseBusinessType(String type) {
    switch (type) {
      case 'restaurant':
        return BusinessType.restaurant;
      case 'fastFood':
        return BusinessType.fastFood;
      case 'shopping':
        return BusinessType.shopping;
      case 'mall':
        return BusinessType.mall;
      case 'hotel':
        return BusinessType.hotel;
      case 'carRental':
        return BusinessType.carRental;
      case 'travelAgency':
        return BusinessType.travelAgency;
      case 'spa':
        return BusinessType.spa;
      case 'cinema':
        return BusinessType.cinema;
      default:
        return BusinessType.other;
    }
  }

  static String _businessTypeToString(BusinessType type) {
    switch (type) {
      case BusinessType.restaurant:
        return 'restaurant';
      case BusinessType.fastFood:
        return 'fastFood';
      case BusinessType.shopping:
        return 'shopping';
      case BusinessType.mall:
        return 'mall';
      case BusinessType.hotel:
        return 'hotel';
      case BusinessType.carRental:
        return 'carRental';
      case BusinessType.travelAgency:
        return 'travelAgency';
      case BusinessType.spa:
        return 'spa';
      case BusinessType.cinema:
        return 'cinema';
      default:
        return 'other';
    }
  }
}