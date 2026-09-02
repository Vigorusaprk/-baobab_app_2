import 'dart:async';

import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/animation/success_check.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// Troisième et dernière étape : c'est fait.
///
/// Rien à appuyer. Le ✓ se trace, le message se lit, et la feuille se referme
/// d'elle-même — on se retrouve sur la page d'où l'on venait. Il y avait
/// auparavant un bouton « Continuer » : trois gestes pour une réussite, là où
/// l'utilisateur n'a plus rien à décider.
class AuthSuccess extends StatefulWidget {
  const AuthSuccess({super.key, required this.onDone});

  /// Appelé quand l'animation est finie et le message lu.
  final VoidCallback onDone;

  @override
  State<AuthSuccess> createState() => _AuthSuccessState();
}

class _AuthSuccessState extends State<AuthSuccess> {
  Timer? _exit;

  /// Le temps de lire le message, après le tracé de la coche. En deçà, la
  /// feuille se refermerait avant qu'on ait vu ce qu'elle disait.
  static const Duration _read = Duration(milliseconds: 900);

  /// Déclenché par [SuccessCheck] à la fin de son animation, pour que la
  /// durée d'attente ne soit pas recopiée ici — elle diverge toujours.
  void _armExit() {
    _exit?.cancel();
    _exit = Timer(AppMotion.duration(context, _read), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _exit?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: SuccessCheck(onFinished: _armExit)),
        AppDimens.spacerMedium,
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
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerLarge,
      ],
    );
  }
}
