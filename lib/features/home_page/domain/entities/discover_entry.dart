import 'business_entity.dart';
import 'discover_offer.dart';
import 'package:equatable/equatable.dart';

/// Une entrée du flux Découvrir, commerce ou offre d'un commerce.
class DiscoverEntry extends Equatable {
  const DiscoverEntry.business(Business value)
    : business = value,
      offer = null;
  const DiscoverEntry.offer(DiscoverOffer value)
    : offer = value,
      business = null;

  final Business? business;
  final DiscoverOffer? offer;

  String get id => business != null
      ? 'business:${business!.id}'
      : 'offer:${offer!.offer.id}';

  String get businessId => business?.id ?? offer?.offer.businessId ?? '';
  String? get offerId => offer?.offer.id;

  @override
  List<Object?> get props => [business, offer];
}
