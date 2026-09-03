import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/core/widgets/custom_pop_up.dart';
import 'package:baobabe_0_2/features/activity/domain/activity_entry.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/activity_receipt.dart';
import 'package:baobabe_0_2/features/activity/presentation/widgets/rate_offer_sheet.dart';
import 'package:baobabe_0_2/features/booking_page/data/models/reservation_service.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/features/order/presentation/widgets/order_service.dart';
import 'package:flutter/material.dart';

/// Le détail d'une commande ou d'une réservation, **en page entière**.
///
/// Il s'ouvrait dans l'onglet, à la place du flux. La barre de navigation
/// restait donc affichée sous un reçu : elle proposait d'aller ailleurs au
/// moment précis où l'on regarde un code à présenter au comptoir, et le
/// dernier bouton du reçu finissait dessous. Un détail n'est pas un onglet :
/// c'est une destination, on y entre et on en revient.
///
/// La page se ferme en rendant `true` quand quelque chose a changé —
/// annulation, note déposée. Le flux ne recharge qu'à ce moment : revenir
/// d'un reçu qu'on a seulement lu ne doit rien coûter.
class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({super.key, required this.entry});

  final ActivityEntry entry;

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  final _orderApi = OrderApiService();
  final _resApi = ReservationApiService();

  /// Ce qui justifie un rechargement du flux au retour.
  bool _changed = false;

  ActivityEntry get _entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final canCancel = _entry.canCancel;
    final canRate = _canRate;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: ActivityReceipt(
        entry: _entry,
        onBack: _close,
        onCancel: canCancel ? _cancel : null,
        onRate: canRate ? _rate : null,
      ),
    );
  }

  bool get _canRate =>
      _entry.order?.status == OrderStatus.delivered &&
      _entry.order!.items.any((i) => i.offerId != null);

  void _close() => Navigator.of(context).pop(_changed);

  // ------------------------------------------------------------- actions

  /// Demande confirmation avant une action irréversible, en nommant ce qui
  /// va être annulé plutôt qu'un « Oui / Non » sans contexte.
  Future<bool> _confirm(String question, String consequence) =>
      showCustomPopUp(context: context, title: question, message: consequence);

  void _notify(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _cancel() async {
    final entry = _entry;
    final isOrder = entry.kind.isOrder;
    if (!await _confirm(
      isOrder
          ? 'Voulez-vous vraiment annuler votre commande ?'
          : 'Voulez-vous vraiment annuler votre réservation ?',
      isOrder
          ? 'Votre commande chez ${entry.businessName} sera annulée. Vous '
                'pourrez en passer une nouvelle quand vous voulez.'
          : 'Votre réservation chez ${entry.businessName} sera supprimée. '
                'Vous pourrez réserver à nouveau quand vous voulez.',
    )) {
      return;
    }

    try {
      if (isOrder) {
        await _orderApi.cancelOrder(entry.id);
      } else {
        await _resApi.deleteReservation(entry.id);
      }
      if (!mounted) return;
      _notify(
        isOrder ? 'Commande annulée.' : 'Réservation supprimée.',
        OtherTheme.of(context).onSuccessContainer,
      );
      // On revient au flux : le reçu d'une chose annulée n'a plus rien à
      // montrer, et son code ne sert plus.
      _changed = true;
      _close();
    } catch (e) {
      debugPrint('Annulation — échec : $e');
      if (!mounted) return;
      _notify(
        isOrder
            ? "La commande n'a pas pu être annulée. Réessayez."
            : "La réservation n'a pas pu être supprimée. Réessayez.",
        Theme.of(context).colorScheme.error,
      );
    }
  }

  /// Propose de noter ce qui a été livré.
  ///
  /// Une commande peut contenir plusieurs offres : on demande d'abord
  /// laquelle, plutôt que d'attribuer arbitrairement la note à la première.
  /// Seules les lignes rattachées à une offre sont notables — les commandes
  /// passées avant le moule `offers` n'en portent pas.
  Future<void> _rate() async {
    final order = _entry.order;
    if (order == null) return;
    final rateable = order.items.where((i) => i.offerId != null).toList();
    if (rateable.isEmpty) return;

    var item = rateable.first;
    if (rateable.length > 1) {
      final chosen = await showCustomBottomSheet<OrderItem>(
        context: context,
        title: 'Que souhaitez-vous noter ?',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final line in rateable)
              ListTile(
                title: Text(line.name),
                onTap: () => Navigator.of(context).pop(line),
              ),
          ],
        ),
      );
      if (chosen == null || !mounted) return;
      item = chosen;
    }

    final rated = await showRateOfferSheet(
      context,
      businessId: order.establishmentId,
      offerId: item.offerId!,
      offerName: item.name,
    );
    if (rated && mounted) setState(() => _changed = true);
  }
}
