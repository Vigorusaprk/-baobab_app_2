import 'package:equatable/equatable.dart';

enum BusinessType {
  restaurant,
  fastFood,
  shopping,
  mall,
  hotel,
  carRental,
  detente,
  travelAgency,
  spa,   // ← NOUVEAU
  other
}

class BusinessReview extends Equatable {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final int likes;
  final int commentCount;

  const BusinessReview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.likes,
    this.commentCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    userName,
    userAvatar,
    rating,
    comment,
    date,
    likes,
    commentCount,
  ];
}

class Business extends Equatable {
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
  final List<Business>? stores;

  const Business({
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

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    description,
    bgImg,
    rating,
    reviewCount,
    openingHours,
    type,
    phone,
    email,
    website,
    images,
    specificData,
    reviews,
    isFavorite,
    latitude,
    longitude,
    stores,
  ];
}