import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// Un chiffre du tableau de bord, avec ce qu'il désigne.
class MerchantStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const MerchantStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimens.allPadding12,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.smallCardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          AppDimens.spacerSmall,
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Pastille de statut, reprise à l'identique pour les commandes et les
/// réservations : le commerçant lit la même forme dans les deux listes.
///
/// [surface] est explicite plutôt qu'obtenue en posant [color] à 12 %
/// d'opacité : le contraste dépendait alors de ce qu'il y avait derrière la
/// pastille, donc invérifiable — et il tombait à 3,8:1 là où un libellé en
/// demande 4,5.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color surface;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.surface = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimens.radius20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Ce qu'on affiche quand une liste est vide, sans faire croire à un
/// chargement qui n'arrive jamais.
class MerchantEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const MerchantEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.secondaryLight),
            AppDimens.spacerMedium,
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            AppDimens.spacerSmall,
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une carte de la liste des commandes, offres ou réservations reçues.
class MerchantCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const MerchantCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimens.smallCardBorderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.smallCardBorderRadius),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    );
  }
}
