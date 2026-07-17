import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:baobabe_0_2/core/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isLoading
                ? const CustomLoadingButton(
                    key: ValueKey('loading'),
                    color: Colors.white,
                  )
                : Text(text, key: const ValueKey('label')),
          ),
        ),
      ),
    );
  }
}
