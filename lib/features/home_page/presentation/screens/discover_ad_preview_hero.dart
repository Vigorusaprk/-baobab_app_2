import 'package:flutter/material.dart';

/// Visuel neutre qui signale la place de l'annonce fictive.
class DiscoverAdPreviewHero extends StatelessWidget {
  const DiscoverAdPreviewHero({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.campaign_outlined,
          size: 72,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }
}
