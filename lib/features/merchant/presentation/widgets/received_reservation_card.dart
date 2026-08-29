import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Une réservation reçue, à confirmer puis à honorer.
class ReceivedReservationCard extends StatelessWidget {
  final ReceivedReservation reservation;

  const ReceivedReservationCard({required this.reservation});

  /// Même grammaire que le cycle d'une commande : ambre tant qu'on attend
  /// une réponse, vert quand c'est accepté, neutre quand c'est derrière
  /// nous, rouge quand c'est arrêté.
  static const Map<ReservationStatus, (Color, Color)> _palette = {
    ReservationStatus.pending: (
      AppColors.warningContent,
      AppColors.warningSurface,
    ),
    ReservationStatus.confirmed: (
      AppColors.successContent,
      AppColors.successSurface,
    ),
    ReservationStatus.cancelled: (
      AppColors.errorContent,
      AppColors.errorSurface,
    ),
    ReservationStatus.completed: (
      AppColors.textSecondary,
      AppColors.background,
    ),
  };

  static const (Color, Color) _fallback = (
    AppColors.textSecondary,
    AppColors.background,
  );

  @override
  Widget build(BuildContext context) {
    final status = reservation.status;

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
                color: (_palette[status] ?? _fallback).$1,
                surface: (_palette[status] ?? _fallback).$2,
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          AppDimens.spacerSmall,
          Row(
            children: [
              if (reservation.total > 0)
                Text(
                  '${reservation.total.toStringAsFixed(2)} \$',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              const Spacer(),
              if (status == ReservationStatus.pending) ...[
                TextButton(
                  onPressed: () => _apply(context, ReservationStatus.cancelled),
                  child: const Text(
                    'Refuser',
                    style: TextStyle(color: AppColors.errorContent),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () => _apply(context, ReservationStatus.confirmed),
                  child: const Text('Confirmer'),
                ),
              ] else if (status == ReservationStatus.confirmed)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () => _apply(context, ReservationStatus.completed),
                  child: const Text('Honorée'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _apply(BuildContext context, ReservationStatus status) async {
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
