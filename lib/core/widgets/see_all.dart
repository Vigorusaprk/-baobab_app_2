import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// Le « Voir tout » d'un titre de section.
///
/// Un mot, petit, dans la couleur secondaire : il accompagne le titre, il ne
/// lui dispute pas la place. Un `TextButton` faisait le contraire — plus
/// gros que le titre, et posé plus bas que lui à cause de sa hauteur
/// minimale.
///
/// Le texte est petit, la cible ne l'est pas : la zone touchable fait la
/// hauteur d'un bouton, autour du mot.
class SeeAll extends StatelessWidget {
  const SeeAll({super.key, this.onTap, this.label = 'Voir tout'});

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.small,
            vertical: AppDimens.small,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
