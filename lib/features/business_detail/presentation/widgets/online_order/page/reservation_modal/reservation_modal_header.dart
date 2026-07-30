import 'package:flutter/material.dart';
import 'package:baobabe_0_2/core/themes/app_colors.dart';

class ReservationModalHeader extends StatelessWidget {
  final String title;
  final String businessName;
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const ReservationModalHeader({
    Key? key,
    required this.title,
    required this.businessName,
    required this.showBack,
    required this.onBack,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
              ),
              onPressed: onBack,
            ),
          if (!showBack) const SizedBox(width: 48),

          Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                businessName,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
