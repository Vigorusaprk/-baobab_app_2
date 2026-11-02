import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/auth/domain/validators/password_validator.dart';
import 'package:flutter/material.dart';

/// Le récapitulatif des règles de mot de passe, mis à jour en direct.
///
/// Chaque règle affiche un ✓ quand elle est satisfaite et un ✗ sinon, à
/// mesure que le champ est rempli — le commerçant valide son mot de
/// passe avant même de le soumettre.
class PasswordRulesHint extends StatefulWidget {
  const PasswordRulesHint({
    super.key,
    required this.controller,
    this.email,
  });

  final TextEditingController controller;
  final String? email;

  @override
  State<PasswordRulesHint> createState() => _PasswordRulesHintState();
}

class _PasswordRulesHintState extends State<PasswordRulesHint> {
  @override
  Widget build(BuildContext context) {
    final password = widget.controller.text.trim();
    final checks = <String, bool>{
      'Au moins ${PasswordValidator.minLength} caractères':
          PasswordValidator.hasMinLength(password),
      'Une lettre et un chiffre': PasswordValidator.hasLetterAndDigit(password),
      'Différent de l\'e-mail': PasswordValidator.isDifferentFromEmail(password, widget.email),
      'Non un mot de passe évident': PasswordValidator.isNotObvious(password),
    };

    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in checks.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.tiny),
            child: Row(
              children: [
                Icon(
                  entry.value ? Icons.check : Icons.cancel,
                  size: 16,
                  color: entry.value
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: AppDimens.small),
                Expanded(
                  child: Text(
                    entry.key,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: entry.value
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
