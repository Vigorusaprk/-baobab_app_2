import 'package:baobabe_0_2/core/animation/press_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OutlinedButtonWithIcon extends StatelessWidget {
  const OutlinedButtonWithIcon({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final String icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PressEffect(
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton.icon(
          icon: SvgPicture.asset(icon, height: 30, width: 30),
          label: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final String icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButtonWithIcon(
      icon: icon,
      label: 'Continuer avec $label',
      onPressed: onPressed,
    );
  }
}
