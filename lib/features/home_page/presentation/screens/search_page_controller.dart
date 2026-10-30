import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_filters_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'explore_pagination.dart';
import 'focus_when_visible.dart';
import 'search_page_view.dart';

/// Porte les contrôleurs et les intentions de l'écran de recherche.
class SearchPageController extends StatefulWidget {
  const SearchPageController({super.key});

  @override
  State<SearchPageController> createState() => _SearchPageControllerState();
}

class _SearchPageControllerState extends State<SearchPageController> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _fieldKey = GlobalKey();
  final _scroll = ScrollController();
  late final ExploreCubit _explore;

  @override
  void initState() {
    super.initState();
    _explore = context.read<ExploreCubit>()..start();
    _scroll.addListener(_onScroll);
    _handleIntent(_explore.state.pendingIntent);
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _handleIntent(ExploreIntent? intent) {
    if (intent == null) return;
    _explore.intentHandled();
    if (intent == ExploreIntent.openFilters) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openFilters();
      });
    } else {
      _focusWhenVisible();
    }
  }

  void _focusWhenVisible() => FocusWhenVisible.request(
    isMounted: () => mounted,
    isAttached: () =>
        _fieldKey.currentContext?.findRenderObject()?.attached ?? false,
    isActive: () => ModalRoute.of(context)?.isCurrent != false,
    requestFocus: _focus.requestFocus,
  );

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (ExplorePagination.shouldLoadMore(
      pixels: position.pixels,
      maxScrollExtent: position.maxScrollExtent,
    )) {
      _explore.loadMore();
    }
  }

  Future<void> _openFilters() async {
    final filters = await showBusinessFiltersSheet(
      context,
      _explore.state.filters,
    );
    if (filters != null) await _explore.filtersChanged(filters);
  }

  @override
  Widget build(BuildContext context) => SearchPageView(
    textController: _text,
    focusNode: _focus,
    fieldKey: _fieldKey,
    scrollController: _scroll,
    onQueryChanged: _explore.queryChanged,
    onOpenFilters: _openFilters,
    onIntent: _handleIntent,
    onRetry: _explore.retry,
    onClearFilters: _explore.clearFacets,
  );
}
