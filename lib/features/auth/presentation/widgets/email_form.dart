import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

/// Première étape de la connexion : l'adresse à laquelle envoyer le code.
///
/// Le titre est porté par l'en-tête de la feuille, pas par ce formulaire :
/// c'est lui qui change d'une étape à l'autre.
class EmailForm extends StatelessWidget {
  const EmailForm({
    super.key,
    required this.email,
    required this.submit,
    this.isLoading = false,
    this.error,
  });

  final TextEditingController email;
  final VoidCallback submit;
  final bool isLoading;

  /// Ce que le serveur a refusé, s'il a refusé. Affiché sous le champ : une
  /// notification en bas d'écran passerait derrière la feuille.
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          validator: validateEmail,
          hintText: 'Adresse e-mail',
          enabled: !isLoading,
        ),
        AppDimens.spacerSmall,
        if (error != null) ...[
          Text(
            error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          AppDimens.spacerSmall,
        ],
        Text(
          'Saisissez votre adresse e-mail. Nous vous enverrons ensuite un '
          'code de confirmation.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppDimens.spacerLarge,
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: email,
          builder: (context, value, _) => CustomButton(
            onPressed: submit,
            text: 'Suivant',
            // Le bouton reste éteint tant que l'adresse ne peut pas
            // recevoir de courrier : proposer d'envoyer un code dans le
            // vide n'aide personne.
            isActive: hasValidEmail(value.text),
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Veuillez entrer une adresse e-mail';
  if (!hasValidEmail(email)) return 'Veuillez entrer une adresse e-mail valide';
  return null;
}

bool hasValidEmail(String value) {
  final email = value.trim();
  if (email.isEmpty) return false;
  return RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);
}
