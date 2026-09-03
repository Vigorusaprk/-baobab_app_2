import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/bloc/offer_detail_cubit.dart';
import 'package:baobabe_0_2/features/business_detail/presentation/widgets/offer_detail_parts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// La barre du bas de la fiche d'une offre.
///
/// Elle portait tout : la ligne de date, le compteur de quantité, le total et
/// le bouton. Quatre décisions empilées au-dessus de la barre de gestes, sur
/// une hauteur qui changeait selon l'offre.
///
/// La date et la quantité sont remontées dans la page, là où on les décide.
/// Il ne reste ici que ce qui conclut : **ce que ça coûte, et le geste**.
class OfferPurchaseBar extends StatelessWidget {
  const OfferPurchaseBar({
    super.key,
    required this.state,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  final OfferDetailLoaded state;
  final VoidCallback onSubmit;

  /// Une validation est en cours. Vient du `CheckoutCubit`, et non de l'état
  /// de la fiche : commander et lire la fiche sont deux choses distinctes.
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final offer = state.detail.offer;
    if (offer.isInStoreOnly) {
      return _Bar(
        child: _InStoreActions(
          businessId: offer.businessId ?? state.detail.merchant?.id,
          phone: state.detail.merchant?.phone,
        ),
      );
    }

    final soldOut = state.detail.isSoldOut;

    return _Bar(
      child: Row(
        children: [
          _Amount(
            label: _label(),
            value: offer.isFree ? 'Sur demande' : offerMoney(state.total),
          ),
          AppDimens.spacerMediumWidth,
          Expanded(
            child: CustomButton(
              text: soldOut
                  ? 'Complet'
                  : offer.isOrderable
                  ? 'Commander'
                  : 'Réserver',
              icon: soldOut
                  ? null
                  : offer.isOrderable
                  ? Icons.shopping_bag_outlined
                  : Icons.event_available_outlined,
              isActive: !soldOut,
              isLoading: isSubmitting,
              onPressed: onSubmit,
            ),
          ),
        ],
      ),
    );
  }

  /// Au-dessus du montant : ce à quoi il correspond. Pour une réservation,
  /// c'est la date retenue — le montant seul ne dit pas pour quand.
  String _label() {
    if (!state.needsDateChoice) {
      final fixed = state.detail.offer.startsAt;
      if (fixed != null) {
        return DateFormat('EEE d MMM · HH:mm', 'fr_FR').format(fixed.toLocal());
      }
      return 'TOTAL';
    }
    final chosen = state.chosenDate;
    if (chosen == null) return 'DATE À CHOISIR';
    return DateFormat('EEE d MMM · HH:mm', 'fr_FR').format(chosen.toLocal());
  }
}

/// Le socle : fond de carte, filet du haut, et la réserve de la barre de
/// gestes du système.
class _Bar extends StatelessWidget {
  const _Bar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant, width: 0.7),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.appPaddingValue,
        AppDimens.small + 4,
        AppDimens.appPaddingValue,
        AppDimens.small + 4,
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Ce qu'on peut faire d'une offre qui ne se prend que sur place : aller voir
/// le commerce, ou l'appeler. Il n'y a rien à valider, donc aucun bouton
/// d'achat — un bouton qui promet une transaction inexistante ment.
class _InStoreActions extends StatelessWidget {
  const _InStoreActions({required this.businessId, required this.phone});

  final String? businessId;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Voir le commerce',
            icon: Icons.storefront_outlined,
            isActive: businessId != null,
            onPressed: () {
              if (businessId != null) context.push('/business/$businessId');
            },
          ),
        ),
        if (phone != null && phone!.isNotEmpty) ...[
          AppDimens.spacerSmallWidth,
          CustomIconButton(
            onPressed: () => _call(phone!),
            tooltip: 'Appeler le commerce',
            icon: Icons.phone_outlined,
            iconSize: AppDimens.medium + 2,
          ),
        ],
      ],
    );
  }

  static Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
