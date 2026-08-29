import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final String hintText;
  final bool enabled;
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.validator,
    required this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      enabled: enabled,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(hintText: hintText),
    );
  }
}
