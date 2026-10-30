import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_bottom_sheet.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_filters.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/discover_filter_groups.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/filter_sheet_parts.dart';
import 'package:flutter/material.dart';

/// Applique en une fois les critères aux deux flux Découvrir.
Future<DiscoverFilters?> showDiscoverFiltersSheet(BuildContext context, DiscoverFilters filters) =>
    showCustomBottomSheet<DiscoverFilters>(context: context, child: _DiscoverFiltersSheet(initial: filters));

class _DiscoverFiltersSheet extends StatefulWidget {
  const _DiscoverFiltersSheet({required this.initial});
  final DiscoverFilters initial;

  @override
  State<_DiscoverFiltersSheet> createState() => _DiscoverFiltersSheetState();
}

class _DiscoverFiltersSheetState extends State<_DiscoverFiltersSheet> {
  late DiscoverFilters _draft = widget.initial;

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    FilterSheetTitle(title: 'Filtrer Découvrir', canClear: _draft.facetCount > 0, onClear: () => setState(() => _draft = const DiscoverFilters())),
    DiscoverFilterGroups(filters: _draft, onChanged: (value) => setState(() => _draft = value)),
    AppDimens.spacerSmall,
    CustomButton(text: 'Appliquer les filtres', onPressed: () => Navigator.pop(context, _draft)),
  ]);
}
