import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer_detail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Le visuel de l'offre, avec l'étiquette qui dit ce qu'on peut en faire.
class OfferDetailHeader extends StatelessWidget {
  final Offer offer;

  const OfferDetailHeader({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final image = offer.displayImage;

    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _ImageFallback(),
            )
          else
            const _ImageFallback(),
          Positioned(
            left: AppDimens.appPaddingValue,
            bottom: AppDimens.appPaddingValue,
            child: OfferBadge(
              label: offer.fulfilment.badge,
              color: offer.isOrderable
                  ? AppColors.secondary
                  : offer.isBookable
                  ? AppColors.primary
                  : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class OfferBadge extends StatelessWidget {
  final String label;
  final Color color;

  const OfferBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Les faits de l'offre : sa date, ses places, son rayon.
///
/// Chaque ligne n'apparaît que si elle a quelque chose à dire — un produit
/// qu'on vient chercher n'a ni date ni jauge.
class OfferFacts extends StatelessWidget {
  final OfferDetail detail;

  const OfferFacts({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final offer = detail.offer;
    final remaining = detail.remainingCapacity;

    final facts = <(IconData, String)>[
      if (offer.startsAt != null)
        (
          Icons.event_outlined,
          DateFormat(
            'EEEE d MMMM à HH:mm',
            'fr_FR',
          ).format(offer.startsAt!.toLocal()),
        ),
      if (remaining != null)
        (
          Icons.event_seat_outlined,
          remaining <= 0
              ? 'Complet'
              : remaining == 1
              ? 'Il reste 1 place'
              : 'Il reste $remaining places',
        ),
      if (offer.section != null && offer.section!.isNotEmpty)
        (Icons.sell_outlined, offer.section!),
    ];

    if (facts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, label) in facts)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textSecondary),
                AppDimens.spacerSmallWidth,
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Chez qui l'offre est proposée, et le lien vers sa fiche.
class OfferMerchantCard extends StatelessWidget {
  final OfferMerchant merchant;

  const OfferMerchantCard({super.key, required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: AppDimens.cardBorderRadiusAll,
      child: InkWell(
        borderRadius: AppDimens.cardBorderRadiusAll,
        onTap: () => context.pushNamed(
          'businessDetail',
          pathParameters: {'id': merchant.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radius12),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: merchant.image != null && merchant.image!.isNotEmpty
                      ? Image.network(
                          merchant.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const _ImageFallback(),
                        )
                      : const _ImageFallback(),
                ),
              ),
              AppDimens.spacerMediumWidth,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    AppDimens.spacerMini,
                    Text(
                      merchant.reviewCount == 0
                          ? (merchant.address ?? 'Voir la fiche')
                          : '${merchant.rating.toStringAsFixed(1)} ★ · '
                                '${merchant.reviewCount} avis',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
