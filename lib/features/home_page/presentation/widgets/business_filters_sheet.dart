import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/business_search_filters.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/filter_sheet_parts.dart';
import 'package:flutter/material.dart';

/// Ouvre la feuille de filtres d'Explorer et rend les critères choisis.
///
/// Les critères d'un commerce ne sont pas ceux d'une offre : ouvert
/// maintenant, et ce qu'on peut y faire. Le prix n'a rien à dire d'un
/// commerce. Ils vivent dans une feuille, derrière le bouton de filtres,
/// et non en rangée de puces sous le champ : la rangée surchargeait l'écran
/// avant même le premier résultat.
///
/// Rend `null` si l'utilisateur referme sans valider : l'appelant garde alors
/// ses filtres courants.
Future<BusinessSearchFilters?> showBusinessFiltersSheet(
  BuildContext context,
  BusinessSearchFilters current,
) {
  return showCustomBottomSheet<BusinessSearchFilters>(
    context: context,
    child: _BusinessFilters(initial: current),
  );
}

class _BusinessFilters extends StatefulWidget {
  const _BusinessFilters({required this.initial});

  final BusinessSearchFilters initial;

  @override
  State<_BusinessFilters> createState() => _BusinessFiltersState();
}

class _BusinessFiltersState extends State<_BusinessFilters> {
  late BusinessSearchFilters _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSheetTitle(
          title: 'Filtrer les commerces',
          canClear: _draft.hasFacets,
          onClear: () => setState(() => _draft = _draft.clearedFacets()),
        ),
        AppDimens.spacerSmall,

        FilterSheetSection(
          title: 'En ce moment',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              FilterSheetChip(
                label: 'Ouvert maintenant',
                icon: Icons.schedule_rounded,
                selected: _draft.openNow,
                onSelected: (on) =>
                    setState(() => _draft = _draft.copyWith(openNow: on)),
              ),
            ],
          ),
        ),

        FilterSheetSection(
          title: 'Ce que je veux y faire',
          child: Wrap(
            spacing: AppDimens.small,
            runSpacing: AppDimens.small,
            children: [
              FilterSheetChip(
                label: 'Commander',
                selected: _draft.canOrder,
                onSelected: (on) =>
                    setState(() => _draft = _draft.copyWith(canOrder: on)),
              ),
              FilterSheetChip(
                label: 'Réserver',
                selected: _draft.canBook,
                onSelected: (on) =>
                    setState(() => _draft = _draft.copyWith(canBook: on)),
              ),
              FilterSheetChip(
                label: 'En boutique',
                selected: _draft.inStore,
                onSelected: (on) =>
                    setState(() => _draft = _draft.copyWith(inStore: on)),
              ),
            ],
          ),
        ),

        AppDimens.spacerMedium,
        CustomButton(
          text: 'Voir les commerces',
          onPressed: () => Navigator.pop(context, _draft),
        ),
      ],
    );
  }
}
