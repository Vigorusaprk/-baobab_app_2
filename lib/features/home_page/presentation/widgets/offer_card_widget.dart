import 'package:baobabe_0_2/core/widgets/remote_image.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Carte d'une **offre** dans les carrousels de l'accueil.
///
/// Volontairement différente de la carte d'un commerçant : on y lit d'abord
/// un prix et le nom du vendeur, là où une carte de commerçant montre une
/// note et une catégorie. C'est ce qui permet de savoir d'un coup d'œil si
/// l'on regarde une chose à acheter ou un endroit où aller — les trois
/// sections de l'accueil étaient auparavant indiscernables.
class OfferCardWidget extends StatelessWidget {
  final Offer offer;
  final VoidCallback onTap;

  const OfferCardWidget({super.key, required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppDimens.cardBorderRadiusAll,
      child: InkWell(
        borderRadius: AppDimens.cardBorderRadiusAll,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: AppDimens.cardBorderRadiusAll,
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _Visual(offer: offer)),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium!,
                      ),
                      if (offer.businessName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'chez ${offer.businessName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              offer.isFree
                                  ? 'Sur demande'
                                  : '${offer.price.toStringAsFixed(0)} \$',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                          if (offer.reviewCount > 0) ...[
                            Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: OtherTheme.of(context).rating,
                            ),
                            Text(
                              offer.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visuel de l'offre, avec l'étiquette qui dit ce qu'on peut en faire.
class _Visual extends StatelessWidget {
  final Offer offer;

  const _Visual({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // `RemoteImage` gère lui-même l'absence d'image et l'échec de
        // chargement : plus besoin d'écrire le repli deux fois.
        RemoteImage(url: offer.displayImage),
        Positioned(
          top: 8,
          left: 8,
          child: _Badge(
            // Dire l'action possible dès la carte évite d'ouvrir une fiche
            // pour découvrir qu'on ne peut que réserver, ou l'inverse — ou
            // qu'il faut simplement passer en boutique.
            label: offer.fulfilment.badge,
            color: offer.isOrderable
                ? Theme.of(context).colorScheme.secondary
                : offer.isBookable
                ? Theme.of(context).colorScheme.primary
                : OtherTheme.of(context).onWarningContainer,
          ),
        ),
        if (offer.startsAt != null)
          Positioned(
            bottom: 8,
            left: 8,
            child: _Badge(
              label: DateFormat('dd/MM').format(offer.startsAt!.toLocal()),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Squelette d'une [OfferCardWidget], à envelopper dans un `Skeletonizer`.
class OfferCardSkeleton extends StatelessWidget {
  const OfferCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: AppDimens.cardBorderRadiusAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 5, child: Bone(width: double.infinity)),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(
                    words: 2,
                    style: Theme.of(context).textTheme.titleMedium!,
                  ),
                  const SizedBox(height: 6),
                  Bone.text(
                    width: 80,
                    style: Theme.of(context).textTheme.bodySmall!,
                  ),
                  const Spacer(),
                  Bone.text(
                    width: 50,
                    style: Theme.of(context).textTheme.bodyMedium!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
