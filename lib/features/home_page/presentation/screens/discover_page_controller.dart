import 'dart:async';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/discover_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/core/services/metrics_service.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/discover_entry.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/discover_filters_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'discover_page_view.dart';
import 'search_page.dart';

/// Relie la demande de recherche de l'accueil à sa page dédiée.
class DiscoverPageController extends StatefulWidget {
  const DiscoverPageController({super.key});

  @override
  State<DiscoverPageController> createState() => _DiscoverPageControllerState();
}

class _DiscoverPageControllerState extends State<DiscoverPageController> {
  late final ExploreCubit _search;
  late final DiscoverCubit _discover;

  @override
  void initState() {
    super.initState();
    _search = context.read<ExploreCubit>();
    _discover = context.read<DiscoverCubit>();
    _openPending(_search.state.pendingIntent);
  }

  void _openPending(ExploreIntent? intent) {
    if (intent == null) return;
    _search.intentHandled();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_pushSearch(intent));
    });
  }
  void _openSearch(ExploreIntent intent) {
    unawaited(_pushSearch(intent));
  }

  Future<void> _pushSearch(ExploreIntent intent) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SearchPageBody.search(initialIntent: intent),
    ),
  );

  Future<void> _openDiscoverFilters() async {
    final filters = await showDiscoverFiltersSheet(
      context,
      _discover.state.filters,
    );
    if (filters != null) await _discover.filtersChanged(filters);
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<ExploreCubit, ExploreState>(
        listenWhen: (before, after) =>
            before.pendingIntent == null && after.pendingIntent != null,
        listener: (context, state) => _openPending(state.pendingIntent),
        child: DiscoverPageView(
          onSearch: () => _openSearch(ExploreIntent.focusSearch),
          onFilters: _openDiscoverFilters,
          onCategorySelected: _discover.categorySelected,
          onRetry: _discover.retry,
          onClearCategory: _discover.resetFilters,
          onLoadMore: _discover.loadMore,
          onSave: _discover.toggleSaved,
          onSkip: _discover.skip,
          onOpenOffer: _openEntry,
        ),
      );
  Future<void> _openEntry(DiscoverEntry entry) async {
    final business = entry.business;
    if (business != null) {
      MetricsService.instance.click(
        businessId: business.id,
        offerId: entry.isAdvertisement ? entry.offerId : null,
      );
      await context.pushNamed(
        'businessDetail',
        pathParameters: {'id': business.id},
      );
      return;
    }
    final offer = entry.offer!.offer;
    MetricsService.instance.click(
      businessId: offer.businessId ?? '',
      offerId: offer.id,
    );
    await context.pushNamed(
      'offerDetail',
      pathParameters: {'id': offer.id},
      extra: offer.fulfilment,
    );
  }
}
