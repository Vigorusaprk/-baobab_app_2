import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SeeAll extends StatelessWidget {
  const SeeAll({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        'Voir tout',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
          fontSize: 13,
        ),
      ),
    );
  }
}
