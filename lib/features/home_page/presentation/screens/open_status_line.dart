import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/themes/other_theme.dart';
import 'package:flutter/material.dart';

/// Statut d'ouverture uniquement quand le serveur l'a fourni.
class OpenStatusLine extends StatelessWidget {
  const OpenStatusLine({super.key, required this.isOpenNow, this.closesAt});

  final bool? isOpenNow;
  final String? closesAt;

  @override
  Widget build(BuildContext context) {
    if (isOpenNow == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final open = isOpenNow!;
    final color = open ? OtherTheme.of(context).success : theme.colorScheme.onSurfaceVariant;
    final label = open && closesAt != null ? "Ouvert jusqu'à $closesAt" : open ? 'Ouvert' : 'Fermé';
    return Padding(padding: const EdgeInsets.only(top: AppDimens.tiny), child: Row(children: [
      Icon(Icons.circle, size: 10, color: color),
      AppDimens.spacerSmallWidth,
      Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: color))),
    ]));
  }
}
