import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';

/// Carte affichant le résumé d'une commande dans la liste des commandes.
class OrderCard extends StatelessWidget {
  final Order order;

  /// Fourni uniquement quand l'annulation est encore possible ; null
  /// masque le bouton plutôt que d'en afficher un qui échouerait.
  final VoidCallback? onCancel;

  /// Proposé une fois la commande livrée : le client note ce qu'il a
  /// réellement reçu. Absent tant que la commande est en cours — il n'y a
  /// rien à juger d'un plat qu'on n'a pas encore goûté.
  final VoidCallback? onRate;

  const OrderCard({super.key, required this.order, this.onCancel, this.onRate});

  @override
  Widget build(BuildContext context) {
    try {
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      return CustomCard(
        child: InkWell(
          onTap: () => context.pushNamed('orderDetail', extra: order),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: order.typeColor(context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        order.typeIcon,
                        color: order.typeColor(context),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.establishmentName,
                            style: Theme.of(context).textTheme.bodyLarge!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: order
                                      .typeColor(context)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.typeName,
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: order.typeColor(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: order.status
                            .color(context)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.displayName,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: order.status.color(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dateFormat.format(order.orderDate),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items
                    .take(2)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x ${item.name}',
                              style: const TextStyle(fontFamily: "Poppins"),
                            ),
                            Text(
                              '${(item.price * item.quantity).toStringAsFixed(2)} \$',
                              style: const TextStyle(fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (order.items.length > 2)
                  Text(
                    '+${order.items.length - 2} autres articles',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: AppDimens.large),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.small,
                    vertical: AppDimens.small,
                  ),
                  decoration: BoxDecoration(
                    color: OtherTheme.of(
                      context,
                    ).success.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppDimens.radius16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(2)} \$',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onCancel != null) ...[
                  const SizedBox(height: AppDimens.small),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Annuler la commande'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                if (onRate != null) ...[
                  const SizedBox(height: AppDimens.small),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: onRate,
                      icon: const Icon(Icons.star_border_rounded, size: 18),
                      label: const Text('Noter ma commande'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('Erreur lors du rendu de la commande : $e');
      debugPrint('$stack');
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Cette ligne n’a pas pu s’afficher.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
