import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/order/domain/entities/order.dart';
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
        backgroundColor: AppColors.transparent,
        title: Text(
          'Détails de la commande',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryLight,
            fontFamily: 'Poppins',
          ),
        ),

        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.background,
              ),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.primary,
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
                    _buildDetailSection('Restaurant', [
                      _buildDetailRow('Nom', order.establishmentName),
                      _buildDetailRow('Type', order.typeName),
                    ]),
                    _buildDetailSection('Date et heure', [
                      _buildDetailRow(
                        'Passée le',
                        dateFormat.format(order.orderDate),
                      ),
                    ]),
                    _buildDetailSection('Articles', [
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
                    _buildDetailSection('Paiement', [
                      _buildDetailRow(
                        'Sous-total',
                        '${order.subtotal.toStringAsFixed(2)} \$',
                      ),
                      _buildDetailRow(
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
                          color: AppColors.success.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radius16,
                          ),
                        ),
                        child: _buildDetailRow(
                          'Total',
                          '${order.totalAmount.toStringAsFixed(2)} \$',
                          isBold: true,
                        ),
                      ),
                    ]),
                    if (order.notes != null && order.notes!.isNotEmpty)
                      _buildDetailSection('Notes', [Text(order.notes!)]),
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
                    child: const Text(
                      'Fermer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.primary,
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
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Recommander',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.background,
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
