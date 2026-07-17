import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_auth_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  void onLogin() {
    // Logique de connexion ici
  }
  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _emailController,
                  builder: (context, value, _) {
                    final hasValidEmail = _hasValidEmail(value.text);
                    return TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        hintText: 'Entrer votre adresse e-mail',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        suffixIcon: hasValidEmail
                            ? CustomAuthIconButton(
                                loading: false,
                                onPressed: _submit,
                              )
                            : null,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    );
                  },
                ),
              ],
            ),
          ),
          
          AppDimens.spacerMedium,
          CustomButton(onPressed: onLogin, text: 'Se connecter'),
        ],
      ),
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
