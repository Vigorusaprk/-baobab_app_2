import 'package:baobabe_0_2/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final String hintText;
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.keyboardType,
    this.validator,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      style: AppFonts.inputTextStyle,
      decoration: InputDecoration(hintText: hintText),
    );
  }
}
