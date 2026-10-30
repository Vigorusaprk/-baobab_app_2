import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:flutter/material.dart';
import 'primary_offer_button.dart';

/// Enregistrer localement ou ouvrir la fiche de l'offre.
class OfferCardActions extends StatelessWidget {
  const OfferCardActions({super.key, required this.offer, required this.saved, required this.onSave, required this.onOpen});

  final DiscoverOffer offer;
  final bool saved;
  final VoidCallback onSave;
  final Future<void> Function() onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(children: [
      Semantics(button: true, label: saved ? 'Retirer des offres enregistrées' : 'Enregistrer cette offre', child: Tooltip(message: saved ? 'Ajouté' : 'Enregistrer', child: Material(
        color: saved ? scheme.primary : scheme.surfaceContainerLowest,
        shape: StadiumBorder(side: BorderSide(color: saved ? scheme.primary : scheme.outlineVariant, width: AppDimens.borderWidthThin)),
        child: InkWell(onTap: onSave, borderRadius: BorderRadius.circular(AppDimens.radius30), child: SizedBox(height: 48, width: saved ? 112 : 48, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: saved ? scheme.onPrimary : scheme.onSurfaceVariant),
          if (saved) ...[AppDimens.spacerMiniWidth, Text('Ajouté', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onPrimary))],
        ]))),
      ))),
      AppDimens.spacerSmallWidth,
      Expanded(child: PrimaryOfferButton(offer: offer, onPressed: onOpen)),
    ]);
  }
}
