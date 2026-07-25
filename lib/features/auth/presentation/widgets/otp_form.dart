import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:flutter/material.dart';

class OtpForm extends StatelessWidget {
  final VoidCallback submit;
  final TextEditingController otp;
  final String email;
  const OtpForm({
    super.key,
    required this.submit,
    required this.otp,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Entrez le code reçu',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Envoyé à $email',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        AppDimens.spacerSmall,
        TextFormField(
          controller: otp,
          keyboardType: TextInputType.emailAddress,
          //validator: _validateEmail,
          decoration: InputDecoration(
            hintText: 'Entrer votre adresse e-mail',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
        AppDimens.spacerMedium,
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: otp,
          builder: (context, value, _) {
            final hasValidEmail = _hasValid(value.text);
            return CustomButton(
              onPressed: submit,
              text: 'Recevoir le code',
              isActive: hasValidEmail,
            );
          },
        ),
      ],
    );
  }

  bool _hasValid(String content) {
    return true;
  }
}
