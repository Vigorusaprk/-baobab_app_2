import 'package:baobabe_0_2/core/animation/animated_count.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_search_field.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Barre de saisie et bouton de filtres de la recherche.
class SearchPageToolbar extends StatelessWidget {
  const SearchPageToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.fieldKey,
    required this.onChanged,
    required this.onFilters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Key fieldKey;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) => Padding(
    padding: AppDimens.appPadding,
    child: Row(
      children: [
        Expanded(
          child: CustomSearchField(
            key: fieldKey,
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppDimens.medium),
        BlocBuilder<ExploreCubit, ExploreState>(
          buildWhen: (a, b) => a.filters.facetCount != b.filters.facetCount,
          builder: (context, state) => Badge(
            isLabelVisible: state.filters.facetCount > 0,
            label: AnimatedCount(value: state.filters.facetCount),
            child: CustomIconButton(
              onPressed: onFilters,
              tooltip: 'Filtrer les commerces',
              assetPath: 'assets/icons/filter.svg',
              tone: IconButtonTone.filled,
              iconSize: 20,
            ),
          ),
        ),
      ],
    ),
  );
}
