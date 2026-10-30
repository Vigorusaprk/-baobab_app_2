import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// Pastille de mode ou de campagne affichée sur la photo.
class OfferCardBadge extends StatelessWidget {
  const OfferCardBadge({super.key, required this.label, required this.dark});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.small, vertical: AppDimens.tiny),
      decoration: BoxDecoration(color: dark ? scheme.inverseSurface : scheme.surface, borderRadius: BorderRadius.circular(AppDimens.radius50)),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: dark ? scheme.onInverseSurface : scheme.onSurface, fontWeight: FontWeight.w700)),
    );
  }
}
