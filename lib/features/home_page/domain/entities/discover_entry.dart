import 'business_entity.dart';
import 'discover_offer.dart';
import 'home_feed.dart';
import 'package:equatable/equatable.dart';

/// Une entrée du flux Découvrir, commerce ou offre d'un commerce.
class DiscoverEntry extends Equatable {
  const DiscoverEntry.business(Business value) : this._(business: value);
  const DiscoverEntry.offer(DiscoverOffer value) : this._(offer: value);
  factory DiscoverEntry.advertisement(FeaturedBusiness value) =>
      DiscoverEntry._(business: value.business, campaign: value);
  const DiscoverEntry.previewAdvertisement()
    : this._(previewAdvertisement: true);

  const DiscoverEntry._({
    this.business,
    this.offer,
    this.campaign,
    this.previewAdvertisement = false,
  });

  final Business? business;
  final DiscoverOffer? offer;
  final FeaturedBusiness? campaign;
  final bool previewAdvertisement;

  String get id => previewAdvertisement
      ? 'ad-preview'
      : campaign != null
      ? 'ad:${campaign!.campaignId}'
      : business != null
      ? 'business:${business!.id}'
      : 'offer:${offer!.offer.id}';

  String get businessId =>
      previewAdvertisement ? '' : business?.id ?? offer?.offer.businessId ?? '';
  String? get offerId => offer?.offer.id ?? campaign?.offer?.id;
  bool get isAdvertisement => campaign != null || previewAdvertisement;
  bool get isPreviewAdvertisement => previewAdvertisement;

  @override
  List<Object?> get props => [business, offer, campaign, previewAdvertisement];
}
