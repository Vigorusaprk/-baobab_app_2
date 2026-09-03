import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ce qu'on voit quand on n'a rien encore demandé.
///
/// Il y en avait deux — un par onglet — qui disaient la même chose deux fois.
/// Le flux étant unique, l'état vide l'est aussi. Il ne s'excuse pas : il dit
/// ce qui apparaîtra ici, et donne le geste qui y mène.
class ActivityEmpty extends StatelessWidget {
  const ActivityEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.large * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Un cercle **tracé** et non rempli : l'accent se pose en
                // ligne, il n'inonde pas.
                border: Border.all(color: scheme.primary),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 30,
                color: scheme.primary,
              ),
            ),
            AppDimens.spacerMedium,
            Text(
              'Rien encore ici',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppDimens.spacerSmall,
            Text(
              'Vos commandes et vos réservations apparaîtront ici, avec leur '
              'statut et le détail de ce que vous avez demandé.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            AppDimens.spacerLarge,
            CustomActionButton(
              label: 'Explorer les commerces',
              icon: Icons.explore_outlined,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
