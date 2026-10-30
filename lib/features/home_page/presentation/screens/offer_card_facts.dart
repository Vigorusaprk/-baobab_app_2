import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Affiche seulement prix, trajet facultatif et note fournis par les données.
class OfferCardFacts extends StatelessWidget {
  const OfferCardFacts({super.key, required this.offer, this.travelTime});

  final DiscoverOffer offer;
  final String? travelTime;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(locale: 'fr_FR', name: offer.offer.currency).format(offer.offer.price);
    return Container(padding: AppDimens.allPadding8, decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(AppDimens.radius12)), child: Row(children: [
      Expanded(child: Text(currency, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium)),
      if (travelTime != null) ...[const Icon(Icons.near_me_outlined, size: 18), AppDimens.spacerMiniWidth, Text(travelTime!, maxLines: 1)],
      if (offer.businessRating != null && offer.businessRating! > 0) ...[
        AppDimens.spacerSmallWidth,
        Icon(Icons.star_rounded, size: 18, color: OtherTheme.of(context).rating),
        AppDimens.spacerMiniWidth,
        Text(offer.businessRating!.toStringAsFixed(1).replaceAll('.', ','), maxLines: 1, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ]));
  }
}
