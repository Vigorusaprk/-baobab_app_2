import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/themes/app_fonts.dart';

class CartHeader extends StatelessWidget {
  const CartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 45, right: 10, left: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 3, color: AppColors.secondary),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.secondary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Liste de Commande',
            style: TextStyle(
              fontFamily: AppFonts.primaryFontFamily,
              fontSize: 24,
              fontWeight: AppFonts.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
