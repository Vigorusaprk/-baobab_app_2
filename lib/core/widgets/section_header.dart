import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/see_all.dart';
import 'package:flutter/material.dart';

/// Le titre d'une section de l'accueil, avec son sous-titre et son « Voir
/// tout » optionnels.
///
/// Le « Voir tout » est **sur la ligne du titre**, centré sur elle, et le
/// sous-titre vient dessous : c'est le titre qu'il prolonge, pas le
/// sous-titre. Posé en bout de colonne, il flottait entre les deux lignes.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      // [SeeAll] porte sa propre marge tactile : on la retire de la marge de
      // page pour que le mot reste aligné sur le bord des cartes.
      padding: AppDimens.appPadding.copyWith(
        right: onSeeAll == null
            ? AppDimens.appPaddingValue
            : AppDimens.appPaddingValue - AppDimens.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (onSeeAll != null) SeeAll(onTap: onSeeAll),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
