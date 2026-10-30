import 'dart:async';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/business_card.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_entry.dart';
import 'package:flutter/material.dart';
import 'discover_ad_preview_card.dart';
import 'offer_card.dart';
import 'offer_card_badge.dart';

/// Affiche un commerce ou une offre avec les gestes propres à chaque type.
class DiscoverEntryCard extends StatelessWidget {
  const DiscoverEntryCard({
    super.key,
    required this.entry,
    required this.sponsored,
    required this.saved,
    required this.onSave,
    required this.onSkip,
    required this.onOpen,
  });

  final DiscoverEntry entry;
  final bool sponsored;
  final bool saved;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverEntry) onOpen;

  @override
  Widget build(BuildContext context) {
    if (entry.isPreviewAdvertisement) {
      return DiscoverAdPreviewCard(onSkip: () => onSkip(entry.id));
    }
    final offer = entry.offer;
    if (offer != null) {
      return OfferCard(
        offer: offer,
        sponsored: sponsored,
        saved: saved,
        onSave: () => onSave(offer.offer.id),
        onSkip: () => onSkip(entry.id),
        onOpen: () => onOpen(entry),
      );
    }
    final business = entry.business!;
    return Stack(
      fit: StackFit.expand,
      children: [
        BusinessCard.tile(
          business: business,
          onTap: () => unawaited(onOpen(entry)),
        ),
        if (sponsored || entry.isAdvertisement)
          Positioned(
            top: AppDimens.small,
            left: AppDimens.small,
            child: OfferCardBadge(
              label: entry.isAdvertisement ? 'PUBLICITÉ' : 'SPONSORISÉ',
              dark: true,
            ),
          ),
        Positioned(
          top: AppDimens.small,
          right: AppDimens.small,
          child: Semantics(
            button: true,
            label: 'Passer ${business.name}',
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => onSkip(entry.id),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
