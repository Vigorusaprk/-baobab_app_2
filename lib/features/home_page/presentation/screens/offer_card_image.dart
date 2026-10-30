import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:flutter/material.dart';
import 'offer_card_badge.dart';
// Le dégradé garde le titre lisible même sur une photo claire.
class OfferCardImage extends StatelessWidget {
  const OfferCardImage({
    super.key,
    required this.offer,
    required this.sponsored,
    required this.onSkip,
  });

  final DiscoverOffer offer;
  final bool sponsored;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = offer.offer;
    return Stack(
      fit: StackFit.expand,
      children: [
        RemoteImage(url: card.displayImage),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.scrim.withValues(alpha: 0),
                scheme.scrim.withValues(alpha: 0.78),
              ],
            ),
          ),
        ),
        Positioned(
          top: AppDimens.small,
          left: AppDimens.small,
          right: AppDimens.small,
          child: Row(
            children: [
              if (sponsored) OfferCardBadge(label: 'SPONSORISÉ', dark: true),
              if (sponsored) AppDimens.spacerMiniWidth,
              OfferCardBadge(
                label: switch (card.fulfilment) {
                  Fulfilment.order => 'À commander',
                  Fulfilment.booking => 'À réserver',
                  Fulfilment.inStore => 'Sur place',
                },
                dark: false,
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'Passer ${card.name}',
                child: Tooltip(
                  message: 'Passer',
                  child: Material(
                    color: scheme.surface.withValues(alpha: 0.94),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onSkip,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.close_rounded,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppDimens.medium,
          right: AppDimens.medium,
          bottom: AppDimens.medium,
          child: Text(
            card.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: scheme.onInverseSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
