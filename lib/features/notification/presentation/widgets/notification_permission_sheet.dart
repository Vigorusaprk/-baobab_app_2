import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/features/notification/domain/notification_reason.dart';
import 'package:flutter/material.dart';

/// Ce que l'utilisateur a répondu à la feuille.
enum PermissionAnswer {
  /// Il accepte : on passe le relais au système.
  accept,

  /// Il refuse, ou il ferme la feuille. Les deux se valent : on n'insiste pas.
  decline,
}

/// Explique **pourquoi** on demande les notifications, avant de le demander.
///
/// Rien n'est accordé ici. C'est un pré-consentement : la feuille donne la
/// raison, et c'est le bouton qui déclenche la vraie boîte de dialogue du
/// système. L'ordre importe — un système refusé ne se redemande pas, et sur
/// Android il ne se redemande jamais après deux refus. Mieux vaut donc avoir
/// exposé la raison avant, plutôt que de brûler la seule occasion sur une
/// boîte qui ne dit rien.
///
/// La raison principale vient de l'action qui vient d'aboutir. Les
/// secondaires sont là pour compléter, en retrait : trois arguments de même
/// poids n'en font aucun.
Future<PermissionAnswer> showNotificationPermissionSheet(
  BuildContext context, {
  required NotificationReason reason,
}) async {
  final answer = await showCustomBottomSheet<PermissionAnswer>(
    context: context,
    title: reason.title,
    child: _Body(reason: reason),
  );
  // Fermer la feuille équivaut à refuser : on ne demandera plus pour cette
  // action. Une fermeture n'est pas une hésitation à exploiter.
  return answer ?? PermissionAnswer.decline;
}

class _Body extends StatelessWidget {
  const _Body({required this.reason});

  final NotificationReason reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDimens.spacerSmall,
        Center(
          child: Container(
            padding: const EdgeInsets.all(AppDimens.medium),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.10),
            ),
            child: Icon(
              reason.icon,
              size: AppDimens.large,
              color: scheme.primary,
            ),
          ),
        ),
        AppDimens.spacerMedium,

        // La raison du moment. C'est elle qui porte la demande.
        Text(
          reason.main,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        AppDimens.spacerLarge,

        // Les raisons secondaires, en retrait.
        for (final item in NotificationReason.secondary) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 18, color: scheme.onSurfaceVariant),
              AppDimens.spacerSmallWidth,
              Expanded(
                child: Text(
                  item.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          AppDimens.spacerSmall,
        ],
        AppDimens.spacerMedium,

        CustomButton(
          text: 'Activer les notifications',
          onPressed: () => Navigator.of(context).pop(PermissionAnswer.accept),
        ),
        AppDimens.spacerSmall,
        Center(
          child: CustomActionButton(
            label: 'Plus tard',
            tone: ActionButtonTone.tonal,
            onPressed: () =>
                Navigator.of(context).pop(PermissionAnswer.decline),
          ),
        ),
      ],
    );
  }
}
