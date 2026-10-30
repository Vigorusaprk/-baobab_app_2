import 'dart:async';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:flutter/material.dart';

enum _OfferButtonStatus { idle, loading, done }

/// Bouton visuel ; l'action ouvre la fiche, elle ne crée pas de commande.
class PrimaryOfferButton extends StatefulWidget {
  const PrimaryOfferButton({super.key, required this.offer, required this.onPressed});

  final DiscoverOffer offer;
  final Future<void> Function() onPressed;

  @override
  State<PrimaryOfferButton> createState() => _PrimaryOfferButtonState();
}

class _PrimaryOfferButtonState extends State<PrimaryOfferButton> {
  _OfferButtonStatus _status = _OfferButtonStatus.idle;

  Future<void> _activate() async {
    if (_status != _OfferButtonStatus.idle) return;
    setState(() => _status = _OfferButtonStatus.loading);
    await widget.onPressed();
    if (!mounted) return;
    setState(() => _status = _OfferButtonStatus.done);
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _status = _OfferButtonStatus.idle);
    });
  }

  String get _label {
    final reservation = widget.offer.offer.fulfilment == Fulfilment.booking;
    final inStore = widget.offer.offer.fulfilment == Fulfilment.inStore;
    return switch (_status) {
      _OfferButtonStatus.idle => inStore ? 'Voir l’offre →' : reservation ? 'Réserver →' : 'Commander →',
      _OfferButtonStatus.loading => inStore ? 'Ouverture…' : reservation ? 'Réservation en cours…' : 'Commande en cours…',
      _OfferButtonStatus.done => 'Ouvert',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(button: true, label: _label, child: SizedBox(height: 52, child: ElevatedButton(
      onPressed: _status == _OfferButtonStatus.idle ? _activate : null,
      style: ElevatedButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary, minimumSize: const Size(48, 52), padding: const EdgeInsets.symmetric(horizontal: AppDimens.medium)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (_status == _OfferButtonStatus.loading) ...[
          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onPrimary)),
          AppDimens.spacerSmallWidth,
        ],
        Flexible(child: Text(_label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w700))),
      ]),
    )));
  }
}
