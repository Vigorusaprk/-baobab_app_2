import 'package:flutter/material.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'discover_page_body.dart';
import 'search_page_controller.dart';

/// Écran public de recherche de commerces ; son API reste inchangée.
class SearchPageBody extends StatelessWidget {
  const SearchPageBody({super.key}) : _search = false, initialIntent = null;

  const SearchPageBody.search({super.key, this.initialIntent}) : _search = true;

  final bool _search;
  final ExploreIntent? initialIntent;

  @override
  Widget build(BuildContext context) => _search
      ? SearchPageController(initialIntent: initialIntent)
      : const DiscoverPageBody();
}
