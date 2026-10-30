import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// Indique la position dans le carrousel sans intercepter le défilement.
class DiscoverPageDots extends StatelessWidget {
  const DiscoverPageDots({super.key, required this.count, required this.selected});

  final int count;
  final int selected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimens.small),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(count, (index) => AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.tiny),
      width: index == selected ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(color: index == selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(AppDimens.radius8)),
    ))),
  );
}
