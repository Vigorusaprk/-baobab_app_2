import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:flutter/material.dart';

/// Troisième et dernière étape : c'est fait.
///
/// L'écran existait sans exister — la feuille se refermait sur-le-champ et
/// l'on se retrouvait à sa page d'avant sans savoir si la connexion avait
/// réussi. Un instant de confirmation coûte peu et répond à la seule question
/// qu'on se pose à ce moment-là.
class AuthSuccess extends StatelessWidget {
  const AuthSuccess({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDimens.spacerMedium,
        Center(
          child: TweenAnimationBuilder<double>(
            duration: AppMotion.duration(context, AppMotion.calm),
            curve: AppMotion.enter,
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) =>
                Transform.scale(scale: 0.7 + 0.3 * value, child: child),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.medium),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Un halo de la même couleur, très pâle : la pastille se
                // détache du fond blanc sans qu'on ait à poser une ombre.
                color: scheme.primary.withValues(alpha: 0.10),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppDimens.medium),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: AppDimens.large,
                  color: scheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
        AppDimens.spacerLarge,
        Text(
          'Connexion réussie',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        AppDimens.spacerSmall,
        Text(
          'Content de vous revoir. Vous êtes maintenant connecté à votre '
          'compte.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerLarge,
        CustomButton(text: 'Continuer', onPressed: onContinue),
      ],
    );
  }
}
