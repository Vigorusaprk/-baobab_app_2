import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/features/auth/domain/validators/password_validator.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/password_field.dart';
import 'package:baobabe_0_2/features/auth/presentation/widgets/password_rules_hint.dart';
import 'package:flutter/material.dart';

/// Le formulaire de définition de mot de passe : mot de passe, confirmation,
/// règles en direct, et action. L'état (repos / chargement / erreur) est
/// porté par le parent ; la saisie vit dans les contrôleurs, jamais vidée.
class SetPasswordForm extends StatefulWidget {
  const SetPasswordForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.error,
    this.email,
  });

  final VoidCallback onSubmit;
  final bool isLoading;
  final String? error;
  final String? email;

  @override
  State<SetPasswordForm> createState() => _SetPasswordFormState();
}

class _SetPasswordFormState extends State<SetPasswordForm> {
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onChanged);
    _confirmationController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _isValid =>
      PasswordValidator.isValid(_passwordController.text, email: widget.email) &&
      _confirmationController.text.trim() == _passwordController.text.trim();

  void _submit() {
    if (!_isValid) return;
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PasswordField(
          controller: _passwordController,
          label: 'Mot de passe',
          hint: '10 caractères minimum, une lettre et un chiffre',
        ),
        AppDimens.spacerSmall,
        PasswordRulesHint(controller: _passwordController, email: widget.email),
        AppDimens.spacerSmall,
        PasswordField(
          controller: _confirmationController,
          label: 'Confirmation',
          hint: 'Saisissez le même mot de passe',
        ),
        if (widget.error != null) ...[
          Text(
            widget.error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          AppDimens.spacerSmall,
        ],
        AppDimens.spacerLarge,
        CustomButton(
          onPressed: _submit,
          text: 'Définir le mot de passe',
          isActive: _isValid && !widget.isLoading,
          isLoading: widget.isLoading,
        ),
      ],
    );
  }
}
