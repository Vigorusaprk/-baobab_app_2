import 'dart:ui';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class MainBackground extends StatelessWidget {
  final Widget child;

  const MainBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // 🔹 Gradient de base
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // 🔹 Blur GLOBAL
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: Colors.white.withOpacity(0.05),
          ),
        ),

        // 🔹 CONTENU
        child,
      ],
    );
  }

}
