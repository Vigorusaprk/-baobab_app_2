import 'package:equatable/equatable.dart';

enum BusinessType {
  all,
  restaurant,
  fastFood,
  shopping,
  mall,
  hotel,
  carRental,
  cinema,
  travelAgency,
  spa,
  tourism,
  other,
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

  factory BusinessReview.fromJson(Map<String, dynamic> json) {
    return BusinessReview(
      id: json['id'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      date: DateTime.parse(json['date'] as String),
      likes: json['likes'] as int,
      commentCount: json['commentCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'likes': likes,
      'commentCount': commentCount,
    };
  }

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
  final List<Business>? stores;
  final bool isSponsored; // 👈 Ajouté pour filtrer les sponsorisés
  final DateTime createdAt; // 👈 Ajouté pour filtrer les nouveautés

  /// Fermeture temporaire déclarée par le commerçant. Le commerce sort de la
  /// découverte sans que rien ne soit supprimé.
  final bool isPaused;
  final String? pauseNote;

  /// L'adresse en colonnes, du plus large au plus précis. [address] reste la
  /// ligne lisible, recomposée par le serveur à chaque changement : elle et
  /// ces six champs ne peuvent donc pas se contredire.
  final String? province;
  final String? ville;
  final String? commune;
  final String? quartier;
  final String? avenue;
  final String? numero;

  /// Le slug de catégorie tel que le serveur le rend. [type] le replie sur
  /// une énumération qui ne connaît pas toutes les catégories de la
  /// plateforme (« cosmetics », « service », « event » deviennent `other`) :
  /// c'est ce slug, et non l'énumération, qui permet de nommer la catégorie
  /// d'après la table `categories`.
  final String categorySlug;

  /// Ce qu'on peut y faire — calculé par le serveur sur les offres actives
  /// (vue `business_card`). C'est ce qui permet à une carte de dire
  /// « Commander », « Réserver », « En boutique » sans ouvrir la fiche.
  final bool canOrder;
  final bool canBook;
  final bool hasInStore;

  /// Ouvert maintenant ?, à l'heure de Kinshasa, décidé par le serveur.
  /// Nul quand la ligne vient d'un point de terminaison qui ne le calcule
  /// pas : on n'affirme alors rien plutôt que de deviner.
  final bool? isOpenNow;
  final String? opensAt;
  final String? closesAt;

  const Business({
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
    this.categorySlug = '',
    this.canOrder = false,
    this.canBook = false,
    this.hasInStore = false,
    this.isOpenNow,
    this.opensAt,
    this.closesAt,
  });

  /// Un commerce sans avis n'est pas un commerce mal noté : la carte dit
  /// « Pas encore d'avis », jamais « 0,0 ».
  bool get hasRating => reviewCount > 0;

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    description,
    bgImg,
    profilImg,
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
    isSponsored,
    createdAt,
    isPaused,
    pauseNote,
    province,
    ville,
    commune,
    quartier,
    avenue,
    numero,
    categorySlug,
    canOrder,
    canBook,
    hasInStore,
    isOpenNow,
    opensAt,
    closesAt,
  ];
}
