import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isActive;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isLoading
                ? Theme.of(context).colorScheme.outlineVariant
                : (isActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppDimens.borderButton),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: isLoading || !isActive ? null : onPressed,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isLoading
                  ? CustomLoadingButton(
                      key: ValueKey('loading'),
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : Text(text, key: const ValueKey('label')),
            ),
          ),
        ),
      ),
    );
  }
}
