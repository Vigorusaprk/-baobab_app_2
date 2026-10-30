import 'package:flutter/material.dart';

/// Titre et contexte de la page d'exploration.
class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Découvrir', maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.headlineMedium),
        Text("Que faire aujourd'hui à Kinshasa ?", maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.bodyLarge),
      ]),
    );
  }
}
