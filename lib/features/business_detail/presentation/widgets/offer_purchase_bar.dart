import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/offer_detail_cubit.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// La barre d'achat, ancrée en bas de la fiche d'une offre.
///
/// Elle n'apparaît que si l'offre se commande ou se réserve : une offre
/// disponible en boutique n'a rien à valider dans l'application, et lui
/// donner un bouton reviendrait à promettre une transaction qui n'existe pas.
class OfferPurchaseBar extends StatelessWidget {
  final OfferDetailLoaded state;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  /// Une validation est en cours. Vient du `CheckoutCubit`, et non de l'état
  /// de la fiche : commander et lire la fiche sont deux choses distinctes.
  final bool isSubmitting;

  const OfferPurchaseBar({
    super.key,
    required this.state,
    required this.onQuantityChanged,
    required this.onPickDate,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    final offer = state.detail.offer;
    if (offer.isInStoreOnly) return const _InStoreNotice();

    final soldOut = state.detail.isSoldOut;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.appPaddingValue,
        12,
        AppDimens.appPaddingValue,
        12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.needsDateChoice) ...[
              _DateRow(
                date: state.chosenDate,
                onTap: soldOut ? null : onPickDate,
              ),
              AppDimens.spacerSmall,
            ],
            // Le montant se lit **au-dessus** du bouton, plus dedans. Dans
            // le bouton, il partageait la place avec le libellé — qui
            // disparaissait sous l'indicateur pendant l'envoi, emportant le
            // prix avec lui — et il changeait la largeur du texte à chaque
            // pas de quantité.
            if (!offer.isFree && !soldOut) ...[
              _TotalRow(total: state.total),
              AppDimens.spacerSmall,
            ],
            Row(
              children: [
                if (!soldOut)
                  _QuantityStepper(
                    quantity: state.quantity,
                    onChanged: onQuantityChanged,
                  ),
                if (!soldOut) AppDimens.spacerMediumWidth,
                Expanded(
                  child: CustomButton(
                    text: soldOut
                        ? 'Complet'
                        : offer.isOrderable
                        ? 'Commander'
                        : 'Réserver',
                    isActive: !soldOut,
                    isLoading: isSubmitting,
                    onPressed: onSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ce qu'on affiche pour une offre qu'on ne peut que venir chercher.
class _InStoreNotice extends StatelessWidget {
  const _InStoreNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(AppDimens.appPaddingValue),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(
              Icons.storefront_outlined,
              color: OtherTheme.of(context).onWarningContainer,
            ),
            AppDimens.spacerMediumWidth,
            Expanded(
              child: Text(
                'Cette offre est à retrouver directement en boutique.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radius30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove, size: 18),
            constraints: const BoxConstraints(
              minWidth: AppDimens.touchTarget,
              minHeight: AppDimens.touchTarget,
            ),
            tooltip: 'Un de moins',
          ),
          Text('$quantity', style: Theme.of(context).textTheme.bodyLarge),
          IconButton(
            onPressed: () => onChanged(quantity + 1),
            icon: const Icon(Icons.add, size: 18),
            constraints: const BoxConstraints(
              minWidth: AppDimens.touchTarget,
              minHeight: AppDimens.touchTarget,
            ),
            tooltip: 'Un de plus',
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime? date;
  final VoidCallback? onTap;

  const _DateRow({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              AppDimens.spacerSmallWidth,
              Expanded(
                child: Text(
                  date == null
                      ? 'Choisir une date'
                      : DateFormat(
                          'EEEE d MMMM à HH:mm',
                          'fr_FR',
                        ).format(date!.toLocal()),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Le total, au-dessus du bouton.
class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '${total.toStringAsFixed(2)} \$',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
