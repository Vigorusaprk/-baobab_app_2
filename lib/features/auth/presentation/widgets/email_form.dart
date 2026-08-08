import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class EmailForm extends StatelessWidget {
  final TextEditingController email;
  final VoidCallback submit;
  final bool isLoading;
  const EmailForm({
    super.key,
    required this.email,
    required this.submit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Se connecter avec email',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        AppDimens.spacerSmall,
        CustomTextFormField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          hintText: 'Entrer votre adresse e-mail',
          enabled: !isLoading,
        ),
        AppDimens.spacerMedium,
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: email,
          builder: (context, value, _) {
            final hasValidEmail = _hasValidEmail(value.text);
            return CustomButton(
              onPressed: submit,
              text: 'Recevoir le code',
              isActive: hasValidEmail,
              isLoading: isLoading,
            );
          },
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Veuillez entrer une adresse e-mail';
    }

    if (!_hasValidEmail(email)) {
      return 'Veuillez entrer une adresse e-mail valide';
    }

    return null;
  }

  bool _hasValidEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) {
      return false;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
