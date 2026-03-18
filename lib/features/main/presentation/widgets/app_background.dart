import 'dart:ui';
import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class authBackground extends StatelessWidget {
  final Widget child;

  const authBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // 🔹 Gradient de base
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight ,
                AppColors.scaffoldBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // 🔹 Formes décoratives
        Positioned(
          top: -80,
          left: -80,
          child: _circle(200, AppColors.scaffoldBackground),
        ),
        Positioned(
          bottom: -80,
          right: -80,
          child: _circle(200, AppColors.primaryLight),
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

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}
