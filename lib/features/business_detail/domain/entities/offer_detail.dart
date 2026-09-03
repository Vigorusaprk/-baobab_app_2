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

  /// Les horaires, tels que le commerçant les a saisis.
  ///
  /// `get-offer-detail` les rapportait déjà — la fiche les jetait. Une offre
  /// qu'on ne peut que venir chercher a pourtant besoin de dire **quand**.
  final Map<String, String> openingHours;

  const OfferMerchant({
    required this.id,
    required this.name,
    this.image,
    this.address,
    this.phone,
    this.rating = 0,
    this.reviewCount = 0,
    this.openingHours = const {},
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
      openingHours: _hours(json['opening_hours']),
    );
  }

  static Map<String, String> _hours(dynamic raw) {
    if (raw is! Map) return const {};
    return {
      for (final entry in raw.entries)
        entry.key.toString(): entry.value?.toString() ?? '',
    };
  }

  /// La ligne du jour, quand elle existe.
  String? get todayHours {
    const days = {
      1: 'lundi',
      2: 'mardi',
      3: 'mercredi',
      4: 'jeudi',
      5: 'vendredi',
      6: 'samedi',
      7: 'dimanche',
    };
    final wanted = days[DateTime.now().weekday];
    for (final entry in openingHours.entries) {
      if (entry.key.trim().toLowerCase() == wanted) {
        return entry.value.trim().isEmpty ? null : entry.value.trim();
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    address,
    phone,
    rating,
    openingHours,
  ];
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
