import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/discover_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/discover_state.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_offer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'discover_content.dart';
import 'discover_search_bar.dart';

/// Structure visuelle de Découvrir : recherche séparée du carrousel d'offres.
class DiscoverPageView extends StatelessWidget {
  const DiscoverPageView({super.key, required this.onSearch, required this.onFilters, required this.onRetry, required this.onClearCategory, required this.onLoadMore, required this.onSave, required this.onSkip, required this.onOpenOffer});

  final VoidCallback onSearch;
  final VoidCallback onFilters;
  final VoidCallback onRetry;
  final VoidCallback onClearCategory;
  final VoidCallback onLoadMore;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onSkip;
  final Future<void> Function(DiscoverOffer) onOpenOffer;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: SafeArea(bottom: false, child: Column(children: [
      const SizedBox(height: AppDimens.headerTopGap),
      DiscoverSearchBar(onSearch: onSearch, onFilters: onFilters),
      AppDimens.spacerSmall,
      Expanded(child: BlocBuilder<DiscoverCubit, DiscoverState>(
        builder: (context, state) {
          final businessState = context.watch<BusinessBloc>().state;
          final sponsored = businessState is BusinessLoaded
              ? businessState.featuredBusinesses.map((item) => item.business.id).toSet()
              : const <String>{};
          return DiscoverContent(state: state, sponsoredBusinessIds: sponsored, onRetry: onRetry, onClearCategory: onClearCategory, onLoadMore: onLoadMore, onSave: onSave, onSkip: onSkip, onOpenOffer: onOpenOffer);
        },
      )),
    ])),
  );
}
