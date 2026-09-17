import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:flutter/material.dart';

/// Les pièces communes aux feuilles de filtres — celle des commerces et
/// celle des offres. Deux feuilles, une seule façon de poser un critère :
/// un titre, des sections, des puces qu'on choisit.

/// L'en-tête d'une feuille de filtres : le titre, et « Tout effacer » quand
/// il y a quelque chose à effacer.
class FilterSheetTitle extends StatelessWidget {
  const FilterSheetTitle({
    super.key,
    required this.title,
    required this.canClear,
    required this.onClear,
  });

  final String title;
  final bool canClear;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
        if (canClear)
          TextButton(
            onPressed: onClear,
            child: Text(
              'Tout effacer',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// Une section de la feuille : un petit titre, puis ses puces.
class FilterSheetSection extends StatelessWidget {
  const FilterSheetSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          AppDimens.spacerSmall,
          child,
        ],
      ),
    );
  }
}

/// Une puce de critère.
class FilterSheetChip extends StatelessWidget {
  const FilterSheetChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      selected: selected,
      onSelected: onSelected,
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 16,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
      label: Text(label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusSmallButton),
      ),
    );
  }
}
