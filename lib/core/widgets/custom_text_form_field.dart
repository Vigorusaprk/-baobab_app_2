import 'package:flutter/material.dart';

/// Le champ de saisie de l'application.
///
/// Tout formulaire passe par lui : l'habillage vient de `inputDecorationTheme`
/// dans `app_theme.dart`, et un écran qui rebâtirait son propre `TextField`
/// finirait par ne plus lui ressembler.
///
/// [label] affiche une étiquette au-dessus du champ. C'est la forme qu'ont
/// prise les formulaires d'adresse et de profil, où deux champs se partagent
/// une ligne : sans étiquette, on ne sait plus lequel est lequel.
class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.maxLines = 1,
  });

  final TextEditingController controller;

  /// Ce qu'on lit dans le champ vide. Obligatoire : un champ sans indication
  /// oblige à deviner ce qu'on attend.
  final String hintText;

  /// Étiquette au-dessus du champ, quand le seul texte d'invite ne suffit pas
  /// à le situer.
  final String? label;

  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      // Le type de clavier demandé est **respecté**. Il était écrasé par
      // `emailAddress` : le champ téléphone de « Devenir commerçant » ouvrait
      // donc un clavier e-mail, et le paramètre ne servait à rien.
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(hintText: hintText, suffixIcon: suffixIcon),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        field,
      ],
    );
  }
}
