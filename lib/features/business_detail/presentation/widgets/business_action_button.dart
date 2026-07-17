import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Bouton d'action rond utilisé dans la section des actions d'un business
/// (réserver, commander, menu, boutiques, ...).
class BusinessActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const BusinessActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = color ?? AppColors.accent700;
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconButton(
                icon: SvgPicture.asset(
                  icon,
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(categoryColor, BlendMode.srcIn),
                ),
                onPressed: onTap,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Bouton d'action rond spécifique au cinéma (utilise une icône Material
/// plutôt qu'un asset SVG).
class BusinessMovieActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const BusinessMovieActionButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = AppColors.primary;
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.movie, size: 28),
                color: categoryColor,
                onPressed: onTap,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voir les films',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
