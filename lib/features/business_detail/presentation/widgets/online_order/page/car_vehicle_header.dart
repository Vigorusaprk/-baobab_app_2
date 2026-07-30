import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// En-tête présentant le nom, le type et le tarif journalier du véhicule.
class CarVehicleHeader extends StatelessWidget {
  final String name;
  final String type;
  final double dailyPrice;

  const CarVehicleHeader({
    super.key,
    required this.name,
    required this.type,
    required this.dailyPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(type, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${dailyPrice.toStringAsFixed(0)}€/jour',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
