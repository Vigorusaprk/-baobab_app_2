import 'package:baobabe_0_2/core/animation/animated_count.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_search_field.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Champ de recherche non éditable : il ouvre l'écran de recherche dédié.
class DiscoverSearchBar extends StatelessWidget {
  const DiscoverSearchBar({super.key, required this.onSearch, required this.onFilters});

  final VoidCallback onSearch;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) => Padding(
    padding: AppDimens.appPadding,
    child: Row(children: [
      Expanded(child: CustomSearchField(readOnly: true, hint: 'Rechercher un plat, un lieu, une sortie', onTap: onSearch)),
      const SizedBox(width: AppDimens.medium),
      BlocBuilder<ExploreCubit, ExploreState>(
        buildWhen: (a, b) => a.filters.facetCount != b.filters.facetCount,
        builder: (context, state) => Badge(isLabelVisible: state.filters.facetCount > 0, label: AnimatedCount(value: state.filters.facetCount), child: CustomIconButton(onPressed: onFilters, tooltip: 'Ouvrir la recherche et ses filtres', assetPath: 'assets/icons/filter.svg', tone: IconButtonTone.filled, iconSize: 20)),
      ),
    ]),
  );
}
