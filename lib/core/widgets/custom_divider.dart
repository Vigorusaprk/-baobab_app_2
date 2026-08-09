import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.textPrimary.withValues(alpha: 0.2),
      height: 1,
      thickness: 0.5,
    );
  }
}
