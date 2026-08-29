import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Détails de la commande',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        leading: IconButton(
          tooltip: 'Retour',
          icon: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: AppDimens.appPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDetailSection(context, 'Restaurant', [
                      _buildDetailRow(context, 'Nom', order.establishmentName),
                      _buildDetailRow(context, 'Type', order.typeName),
                    ]),
                    _buildDetailSection(context, 'Date et heure', [
                      _buildDetailRow(
                        context,
                        'Passée le',
                        dateFormat.format(order.orderDate),
                      ),
                    ]),
                    _buildDetailSection(context, 'Articles', [
                      if (order.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Aucun article de commande disponible.'),
                        )
                      else
                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${item.quantity}x ${item.name}'),
                                ),
                                Text(
                                  '${(item.price * item.quantity).toStringAsFixed(2)} \$',
                                ),
                              ],
                            ),
                          ),
                        ),
                    ]),
                    _buildDetailSection(context, 'Paiement', [
                      _buildDetailRow(
                        context,
                        'Sous-total',
                        '${order.subtotal.toStringAsFixed(2)} \$',
                      ),
                      _buildDetailRow(
                        context,
                        'Taxes',
                        '${order.tax.toStringAsFixed(2)} \$',
                      ),

                      SizedBox(height: AppDimens.large),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.small,
                          vertical: AppDimens.small,
                        ),
                        decoration: BoxDecoration(
                          color: OtherTheme.of(
                            context,
                          ).success.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radius16,
                          ),
                        ),
                        child: _buildDetailRow(
                          context,
                          'Total',
                          '${order.totalAmount.toStringAsFixed(2)} \$',
                          isBold: true,
                        ),
                      ),
                    ]),
                    if (order.notes != null && order.notes!.isNotEmpty)
                      _buildDetailSection(context, 'Notes', [
                        Text(order.notes!),
                      ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Fermer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à implémenter'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      'Recommander',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: isBold
                ? Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
