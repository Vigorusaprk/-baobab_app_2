import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:flutter/material.dart';
import 'offer_card_facts.dart';
import 'open_status_line.dart';

/// Nom du commerce, ouverture, prix, note et capacité déclarée.
class OfferCardInfo extends StatelessWidget {
  const OfferCardInfo({super.key, required this.offer});
  final DiscoverOffer offer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final place = offer.quartier ?? offer.commune;
    final capacity = offer.offer.fulfilment == Fulfilment.inStore ? null : offer.offer.capacity;
    final remaining = switch (offer.offer.fulfilment) {
      Fulfilment.order => capacity == null ? null : '$capacity portions restantes',
      Fulfilment.booking => capacity == null ? null : '$capacity places restantes',
      Fulfilment.inStore => null,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (offer.offer.businessName != null)
        Text([offer.offer.businessName, if (place != null && place.isNotEmpty) place].join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
      OpenStatusLine(isOpenNow: offer.isOpenNow, closesAt: offer.closesAt),
      AppDimens.spacerSmall,
      OfferCardFacts(offer: offer, travelTime: offer.travelTime),
      if (remaining != null) ...[
        AppDimens.spacerSmall,
        Text(remaining, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    ]);
  }
}
