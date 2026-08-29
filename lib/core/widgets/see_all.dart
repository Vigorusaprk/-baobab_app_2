import 'package:flutter/material.dart';

class SeeAll extends StatelessWidget {
  const SeeAll({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        'Voir tout',
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
