import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
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

  const OrderCard({
    super.key,
    required this.order,
    this.onCancel,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

      return Card(
        color: AppColors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        color: order.typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        order.typeIcon,
                        color: order.typeColor,
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
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
                                  color: order.typeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.typeName,
                                  style: TextStyle(
                                    color: order.typeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Poppins",
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
                        color: order.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.displayName,
                        style: TextStyle(
                          color: order.status.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dateFormat.format(order.orderDate),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: "Poppins",
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
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontFamily: "Poppins",
                    ),
                  ),
                const SizedBox(height: AppDimens.large),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.small,
                    vertical: AppDimens.small,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppDimens.radius16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(2)} \$',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                          fontFamily: "Poppins",
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
                        foregroundColor: AppColors.error,
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
                        foregroundColor: AppColors.primary,
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
      print('Erreur lors du rendu de la commande : $e');
      print(stack);
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Erreur d’affichage : $e'),
        ),
      );
    }
  }
}
