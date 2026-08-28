import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/review.dart';
import 'package:equatable/equatable.dart';

/// Le commerçant qui propose l'offre, réduit à ce qu'une fiche d'offre a
/// besoin d'en dire.
///
/// Volontairement plus léger que `Business` : on arrive ici sans être passé
/// par la fiche du commerce, et charger tout son catalogue pour afficher son
/// nom serait payer cher un lien hypertexte.
class OfferMerchant extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String? address;
  final String? phone;
  final double rating;
  final int reviewCount;

  const OfferMerchant({
    required this.id,
    required this.name,
    this.image,
    this.address,
    this.phone,
    this.rating = 0,
    this.reviewCount = 0,
  });

  factory OfferMerchant.fromJson(Map<String, dynamic> json) {
    return OfferMerchant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['bgImg']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, image, address, phone, rating];
}

/// Tout ce qu'il faut pour décider devant une offre.
class OfferDetail extends Equatable {
  final Offer offer;
  final OfferMerchant? merchant;
  final List<Review> reviews;

  /// Autres offres du même commerçant, pour rebondir sans repasser par sa
  /// fiche.
  final List<Offer> otherOffers;

  /// Places encore libres, quand le commerçant en déclare. Calculé par le
  /// serveur : afficher « disponible » sur une offre complète ne mène
  /// l'utilisateur qu'à un refus au moment de valider.
  final int? remainingCapacity;

  const OfferDetail({
    required this.offer,
    this.merchant,
    this.reviews = const [],
    this.otherOffers = const [],
    this.remainingCapacity,
  });

  /// L'offre peut-elle encore être prise ? Faux uniquement quand une jauge
  /// existe et qu'elle est épuisée.
  bool get isSoldOut => remainingCapacity != null && remainingCapacity! <= 0;

  @override
  List<Object?> get props => [
    offer,
    merchant,
    reviews,
    otherOffers,
    remainingCapacity,
  ];
}
