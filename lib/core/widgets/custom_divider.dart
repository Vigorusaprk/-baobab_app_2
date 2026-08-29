import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
      height: 1,
      thickness: 0.5,
    );
  }
}
