import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/merchant/domain/entities/merchant_space.dart';
import 'package:baobabe_0_2/features/merchant/presentation/cubit/merchant_cubit.dart';
import 'package:baobabe_0_2/features/merchant/presentation/widgets/merchant_widgets.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Une commande reçue, avec le seul geste qui a du sens à cet instant.
class ReceivedOrderCard extends StatelessWidget {
  final ReceivedOrder order;

  const ReceivedOrderCard({required this.order});

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
                color: order.status.color,
                surface: order.status.surface,
              ),
            ],
          ),
          if (order.createdAt != null) ...[
            AppDimens.spacerMini,
            Text(
              DateFormat('dd/MM à HH:mm').format(order.createdAt!.toLocal()),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          AppDimens.spacerSmall,
          Row(
            children: [
              Text(
                '${order.total.toStringAsFixed(2)} \$',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              if (canRefuse)
                TextButton(
                  onPressed: () => _apply(context, OrderStatus.cancelled),
                  child: const Text(
                    'Refuser',
                    style: TextStyle(color: AppColors.errorContent),
                  ),
                ),
              if (next != null)
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () => _apply(context, next.$1),
                  child: Text(next.$2),
                ),
            ],
          ),
          if (order.customer?.phone != null) ...[
            AppDimens.spacerMini,
            Text(
              order.customer!.phone!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _apply(BuildContext context, OrderStatus status) async {
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
