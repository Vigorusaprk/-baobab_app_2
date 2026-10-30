import 'package:baobabe_0_2/core/animation/fade_swap.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_page_toolbar.dart';
import 'explore_results.dart';

/// Mise en page de la recherche, sans posséder ses contrôleurs.
class SearchPageView extends StatelessWidget {
  const SearchPageView({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.fieldKey,
    required this.scrollController,
    required this.onQueryChanged,
    required this.onOpenFilters,
    required this.onIntent,
    required this.onRetry,
    required this.onClearFilters,
  });

  final TextEditingController textController;
  final FocusNode focusNode;
  final Key fieldKey;
  final ScrollController scrollController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onOpenFilters;
  final ValueChanged<ExploreIntent?> onIntent;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: AppDimens.headerTopGap),
          SearchPageToolbar(
            controller: textController,
            focusNode: focusNode,
            fieldKey: fieldKey,
            onChanged: onQueryChanged,
            onFilters: onOpenFilters,
          ),
          AppDimens.spacerSmall,
          BlocBuilder<ExploreCubit, ExploreState>(
            buildWhen: (a, b) =>
                a.filters.categorySlug != b.filters.categorySlug,
            builder: (context, state) => CategoryIcons(
              collapseProgress: 1,
              selectedSlug: state.filters.categorySlug ?? 'all',
              onCategorySelected: context.read<ExploreCubit>().categorySelected,
            ),
          ),
          AppDimens.spacerSmall,
          Expanded(
            child: BlocConsumer<ExploreCubit, ExploreState>(
              listenWhen: (a, b) =>
                  a.pendingIntent == null && b.pendingIntent != null,
              listener: (context, state) => onIntent(state.pendingIntent),
              builder: (context, state) => FadeSwap(
                child: ExploreResults(
                  state: state,
                  scroll: scrollController,
                  onRetry: onRetry,
                  onClearFilters: onClearFilters,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
