import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:flutter/material.dart';
import 'offer_card_actions.dart';
import 'offer_card_image.dart';
import 'offer_card_info.dart';

/// Carte adaptative d'une offre dans le carrousel Découvrir.
class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, required this.sponsored, required this.saved, required this.onSave, required this.onSkip, required this.onOpen});

  final DiscoverOffer offer;
  final bool sponsored;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onSkip;
  final Future<void> Function() onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final imageFlex = constraints.maxHeight < 420 ? 3 : 4;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      elevation: AppDimens.elevationDefault,
      shadowColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
      borderRadius: AppDimens.cardBorderRadiusAll,
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Expanded(flex: imageFlex, child: OfferCardImage(offer: offer, sponsored: sponsored, onSkip: onSkip)),
        Flexible(flex: 5, child: SingleChildScrollView(padding: AppDimens.allPadding12, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          OfferCardInfo(offer: offer),
          AppDimens.spacerSmall,
          OfferCardActions(offer: offer, saved: saved, onSave: onSave, onOpen: onOpen),
        ]))),
      ]),
    );
  });
}
