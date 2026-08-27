import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Ligne d'une offre dans le catalogue, avec son sélecteur de quantité.
///
/// Reprend la carte blanche arrondie déjà utilisée partout dans l'app
/// plutôt que d'introduire un style propre à cet écran.
class OfferTile extends StatelessWidget {
  final Offer offer;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const OfferTile({
    super.key,
    required this.offer,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = quantity > 0;

    return Container(
      padding: AppDimens.allPadding12,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppDimens.cardBorderRadiusAll,
        border: Border.all(
          color: selected ? AppColors.secondary : AppColors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  offer.name,
                  style: AppFonts.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (offer.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    offer.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      offer.isFree
                          ? 'Prix à confirmer'
                          : '${offer.price.toStringAsFixed(2)} \$',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (offer.startsAt != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          DateFormat(
                            'dd/MM à HH:mm',
                          ).format(offer.startsAt!.toLocal()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
                if (offer.capacity != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${offer.capacity} places',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _QuantityStepper(
            quantity: quantity,
            max: offer.capacity,
            onChanged: onQuantityChanged,
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final int? max;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({
    required this.quantity,
    required this.onChanged,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        height: 36,
        child: OutlinedButton(
          onPressed: () => onChanged(1),
          child: const Text('Ajouter'),
        ),
      );
    }

    // On plafonne à la capacité déclarée quand il y en a une, pour ne pas
    // laisser réserver plus de places qu'il n'en existe.
    final canIncrement = max == null || quantity < max!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onChanged(quantity - 1),
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.primary,
          visualDensity: VisualDensity.compact,
        ),
        Text('$quantity', style: AppFonts.titleMedium),
        IconButton(
          onPressed: canIncrement ? () => onChanged(quantity + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.primary,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

/// Squelette d'une [OfferTile], à envelopper dans un `Skeletonizer`.
class OfferTileSkeleton extends StatelessWidget {
  const OfferTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimens.allPadding12,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppDimens.cardBorderRadiusAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Bone.text(width: 150, style: AppFonts.titleMedium),
                const SizedBox(height: 6),
                Bone.multiText(lines: 2, style: AppFonts.bodySmall),
                const SizedBox(height: 6),
                Bone.text(width: 60, style: AppFonts.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Bone.button(width: 84, height: 36, uniRadius: 20),
        ],
      ),
    );
  }
}
