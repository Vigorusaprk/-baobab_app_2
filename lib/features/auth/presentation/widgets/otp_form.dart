import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/otp_code_field.dart';
import 'package:flutter/material.dart';

/// Deuxième étape : le code à six chiffres reçu par courriel.
///
/// Les trois états du code — en cours de saisie, refusé, vérifié — se lisent
/// sur les cases elles-mêmes, et sont redits en toutes lettres au-dessus de
/// l'explication : la couleur seule ne suffit pas à qui la distingue mal.
class OtpForm extends StatelessWidget {
  const OtpForm({
    super.key,
    required this.submit,
    required this.otp,
    required this.email,
    this.isLoading = false,
    this.status = OtpStatus.editing,
  });

  final VoidCallback submit;
  final TextEditingController otp;
  final String email;
  final bool isLoading;
  final OtpStatus status;

  static const int _length = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OtpCodeField(
          controller: otp,
          length: _length,
          status: status,
          enabled: !isLoading,
        ),
        AppDimens.spacerMedium,
        if (status != OtpStatus.editing) ...[
          Text(
            status == OtpStatus.invalid
                ? 'Code invalide. Veuillez réessayer.'
                : 'Code vérifié.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: status == OtpStatus.invalid
                  ? theme.colorScheme.error
                  : OtherTheme.of(context).success,
            ),
          ),
          AppDimens.spacerSmall,
        ],
        Text.rich(
          TextSpan(
            text:
                'Pour confirmer votre compte, saisissez le code à '
                '$_length chiffres que nous avons envoyé à ',
            children: [
              TextSpan(
                // L'adresse est mise en avant : c'est ce qu'on relit quand
                // le code n'arrive pas.
                text: email,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerLarge,
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: otp,
          builder: (context, value, _) => CustomButton(
            onPressed: submit,
            text: 'Suivant',
            isActive: value.text.length == _length,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
