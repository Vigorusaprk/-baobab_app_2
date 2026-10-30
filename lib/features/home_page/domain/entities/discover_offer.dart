import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';

/// Données d'offre et champs du commerce utiles à la carte Découvrir.
class DiscoverOffer {
  const DiscoverOffer({
    required this.offer,
    this.quartier,
    this.commune,
    this.businessRating,
    this.isOpenNow,
    this.closesAt,
    this.travelTime,
  });

  final Offer offer;
  final String? quartier;
  final String? commune;
  final double? businessRating;
  final bool? isOpenNow;
  final String? closesAt;

  /// TODO : alimenter ce champ quand le backend fournira une distance.
  final String? travelTime;

  factory DiscoverOffer.fromJson(Map<String, dynamic> json) {
    final raw = json['business'];
    final Map<String, dynamic> business = raw is Map
        ? Map<String, dynamic>.from(raw)
        : const {};
    final rating = business['rating'];
    return DiscoverOffer(
      offer: Offer.fromJson(json),
      quartier: (business['quartier'] ?? business['district'])?.toString(),
      commune: business['commune']?.toString(),
      businessRating: rating is num ? rating.toDouble() : null,
      isOpenNow: business['is_open_now'] as bool?,
      closesAt: business['closes_at']?.toString(),
    );
  }
}
