import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_pop_up.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';

/// Une réservation reçue, à confirmer puis à honorer.
class ReceivedReservationCard extends StatelessWidget {
  final ReceivedReservation reservation;

  const ReceivedReservationCard({super.key, required this.reservation});

  /// Même grammaire que le cycle d'une commande : ambre tant qu'on attend
  /// une réponse, vert quand c'est accepté, neutre quand c'est derrière
  /// nous, rouge quand c'est arrêté.
  (Color, Color) _palette(BuildContext context, ReservationStatus status) {
    final other = OtherTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case ReservationStatus.pending:
        return (other.onWarningContainer, other.warningContainer);
      case ReservationStatus.confirmed:
        return (other.onSuccessContainer, other.successContainer);
      case ReservationStatus.cancelled:
        return (scheme.error, scheme.errorContainer);
      case ReservationStatus.completed:
        return (scheme.onSurfaceVariant, scheme.surface);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = reservation.status;
    // Voir [ReceivedOrderCard] : on ne double pas une demande en vol.
    final merchantState = context.watch<MerchantCubit>().state;
    final busy = merchantState is MerchantReady && merchantState.isWorking;

    return MerchantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reservation.customer?.name ?? 'Client',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              StatusChip(
                label: status.label,
                color: _palette(context, status).$1,
                surface: _palette(context, status).$2,
              ),
            ],
          ),
          AppDimens.spacerMini,
          Text(
            '${reservation.quantity} × ${reservation.itemName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (reservation.date != null)
            Text(
              DateFormat(
                'EEEE d MMMM à HH:mm',
                'fr_FR',
              ).format(reservation.date!.toLocal()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          AppDimens.spacerSmall,
          Row(
            children: [
              if (reservation.total > 0)
                Text(
                  '${reservation.total.toStringAsFixed(2)} \$',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              const Spacer(),
              if (status == ReservationStatus.pending) ...[
                CustomActionButton(
                  label: 'Refuser',
                  tone: ActionButtonTone.danger,
                  onPressed: busy
                      ? null
                      : () => _apply(context, ReservationStatus.cancelled),
                ),
                AppDimens.spacerSmallWidth,
                CustomActionButton(
                  label: 'Confirmer',
                  onPressed: busy
                      ? null
                      : () => _apply(context, ReservationStatus.confirmed),
                ),
              ] else if (status == ReservationStatus.confirmed)
                CustomActionButton(
                  label: 'Honorée',
                  onPressed: busy
                      ? null
                      : () => _apply(context, ReservationStatus.completed),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _apply(BuildContext context, ReservationStatus status) async {
    // Même règle que pour une commande : refuser annule le rendez-vous du
    // client sans retour possible, et le bouton borde « Confirmer ».
    if (status == ReservationStatus.cancelled) {
      final confirmed = await showCustomPopUp(
        context: context,
        title: 'Refuser cette réservation ?',
        message:
            'Le créneau est libéré tout de suite et le client en est '
            'prévenu. Cela ne peut pas être défait.',
        confirmLabel: 'Refuser',
      );
      if (!confirmed || !context.mounted) return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<MerchantCubit>().updateReservationStatus(
      reservation.id,
      status.asJson,
    );
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Réservation ${status.label}')),
    );
  }
}
