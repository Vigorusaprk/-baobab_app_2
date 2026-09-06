import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_pop_up.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';

/// Une commande reçue, avec le seul geste qui a du sens à cet instant.
class ReceivedOrderCard extends StatelessWidget {
  final ReceivedOrder order;

  const ReceivedOrderCard({super.key, required this.order});

  /// L'étape suivante d'une commande. Le commerçant n'a jamais à choisir
  /// dans une liste de six statuts : il confirme, puis prépare, puis
  /// signale que c'est prêt. Un seul bouton à la fois.
  static const Map<OrderStatus, (OrderStatus, String)> _nextStep = {
    OrderStatus.pending: (OrderStatus.confirmed, 'Accepter'),
    OrderStatus.confirmed: (OrderStatus.preparing, 'Préparer'),
    OrderStatus.preparing: (OrderStatus.ready, 'Prête'),
    OrderStatus.ready: (OrderStatus.delivered, 'Remise au client'),
  };

  @override
  Widget build(BuildContext context) {
    final next = _nextStep[order.status];
    // Un changement de statut est en vol : on ferme les boutons plutôt que
    // d'en envoyer un second par-dessus.
    final merchantState = context.watch<MerchantCubit>().state;
    final busy = merchantState is MerchantReady && merchantState.isWorking;
    final canRefuse =
        order.status == OrderStatus.pending ||
        order.status == OrderStatus.confirmed;

    return MerchantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.customer?.name ?? 'Client',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              StatusChip(
                label: order.status.displayName,
                color: order.status.color(context),
                surface: order.status.surface(context),
              ),
            ],
          ),
          if (order.createdAt != null) ...[
            AppDimens.spacerMini,
            Text(
              DateFormat('dd/MM à HH:mm').format(order.createdAt!.toLocal()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          AppDimens.spacerSmall,
          for (final line in order.lines)
            Text(
              '${line.quantity} × ${line.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            AppDimens.spacerMini,
            Text(
              'Note : ${order.notes}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          AppDimens.spacerSmall,
          Text(
            '${order.total.toStringAsFixed(2)} \$',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Les actions sur leur propre ligne : à la suite du montant, deux
          // boutons débordaient de la rangée sur un téléphone, et Flutter
          // n'envoie pas les touchers au-delà des limites du parent — le
          // dernier bouton était peint en entier mais mort sur sa droite.
          if (canRefuse || next != null) ...[
            AppDimens.spacerSmall,
            Row(
              children: [
                if (canRefuse) ...[
                  Expanded(
                    child: CustomActionButton(
                      label: 'Refuser',
                      tone: ActionButtonTone.danger,
                      onPressed: busy
                          ? null
                          : () => _apply(context, OrderStatus.cancelled),
                    ),
                  ),
                  AppDimens.spacerSmallWidth,
                ],
                if (next != null)
                  Expanded(
                    child: CustomActionButton(
                      label: next.$2,
                      onPressed: busy ? null : () => _apply(context, next.$1),
                    ),
                  ),
              ],
            ),
          ],
          if (order.customer?.phone != null) ...[
            AppDimens.spacerMini,
            Text(
              order.customer!.phone!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _apply(BuildContext context, OrderStatus status) async {
    // Refuser est sans retour pour le client : sa commande est annulée à
    // l'instant, et il en est averti. On le nomme avant de le faire — le
    // bouton borde « Préparer », et les deux se touchent du pouce.
    if (status == OrderStatus.cancelled) {
      final confirmed = await showCustomPopUp(
        context: context,
        title: 'Refuser cette commande ?',
        message:
            'Elle est annulée tout de suite et le client en est prévenu. '
            'Cela ne peut pas être défait.',
        confirmLabel: 'Refuser',
      );
      if (!confirmed || !context.mounted) return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<MerchantCubit>().updateOrderStatus(
      order.id,
      status.name,
    );
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Commande ${status.displayName}')),
    );
  }
}
