import 'dart:async';

import 'package:baobabe_0_2/core/animation/app_motion.dart';
import 'package:baobabe_0_2/core/animation/success_check.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/features/order/presentation/cubit/checkout_cubit.dart';
import 'package:flutter/material.dart';

/// La confirmation d'une commande ou d'une réservation.
///
/// Même forme que la fin de la connexion par code : la coche se trace, le
/// message se lit, la feuille se referme d'elle-même. Rien à appuyer.
///
/// Ce qu'elle remplace : la feuille d'adresse se fermait, le bouton tournait,
/// puis la page entière repassait en squelette. Trois signaux qui ne disaient
/// pas « c'est fait » — le dernier disait même le contraire, puisqu'un
/// squelette veut dire « ça charge ».
Future<void> showCheckoutSuccessSheet(
  BuildContext context, {
  required CheckoutKind kind,
}) {
  return showCustomBottomSheet<void>(
    context: context,
    // Pas de croix : la feuille part d'elle-même, et une croix inviterait à
    // interrompre une animation d'une seconde et demie.
    showCloseButton: false,
    child: _Body(kind: kind),
  );
}

class _Body extends StatefulWidget {
  const _Body({required this.kind});

  final CheckoutKind kind;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  Timer? _exit;

  /// Le temps de lire, après le tracé de la coche.
  static const Duration _read = Duration(milliseconds: 900);

  /// Déclenché par [SuccessCheck] à la fin de son animation, pour que la
  /// durée d'attente ne soit pas recopiée ici — elle diverge toujours.
  void _armExit() {
    _exit?.cancel();
    _exit = Timer(AppMotion.duration(context, _read), () {
      if (mounted) Navigator.of(context).maybePop();
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
    final isOrder = widget.kind.isOrder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: SuccessCheck(onFinished: _armExit)),
        AppDimens.spacerMedium,
        Text(
          isOrder ? 'Commande envoyée' : 'Demande envoyée',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        AppDimens.spacerSmall,
        Text(
          isOrder
              ? 'Le commerçant l\'a reçue. Suivez-la dans Mes activités.'
              : 'Le commerçant doit la confirmer. Vous la retrouverez dans '
                    'Mes activités.',
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
