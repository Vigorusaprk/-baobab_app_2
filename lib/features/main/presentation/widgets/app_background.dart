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
        // 🔹 Dégradé 3 couleurs (avec les couleurs de l'app)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                AppColors.primaryLight, // beige clair
                AppColors.primary,      // beige moyen
                AppColors.primaryDark,  // beige foncé
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // 🔹 Cercles décoratifs (effet verre / profondeur)
        // Cercle 1 – grand, flou, en haut à droite
        Positioned(
          top: -80,
          right: -60,
          child: _glassCircle(
            size: 300,
            opacity: 0.10,
            blur: 80,
          ),
        ),
        // Cercle 2 – moyen, en bas à gauche
        Positioned(
          bottom: -40,
          left: -40,
          child: _glassCircle(
            size: 250,
            opacity: 0.08,
            blur: 60,
          ),
        ),
        // Cercle 3 – petit reflet en haut à gauche
        Positioned(
          top: 100,
          left: -20,
          child: _glassCircle(
            size: 120,
            opacity: 0.15,
            blur: 40,
          ),
        ),
        // Cercle 4 – autre reflet en bas à droite
        Positioned(
          bottom: 120,
          right: -30,
          child: _glassCircle(
            size: 180,
            opacity: 0.10,
            blur: 70,
          ),
        ),

        // 🔹 CONTENU (ton formulaire, carte, etc.)
        child,
      ],
    );
  }

  // Cercle avec effet de flou lumineux (comme du verre dépoli)
  Widget _glassCircle({
    required double size,
    required double opacity,
    required double blur,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(opacity * 0.6),
            blurRadius: blur,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}