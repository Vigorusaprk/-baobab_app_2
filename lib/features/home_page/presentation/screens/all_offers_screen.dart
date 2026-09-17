import 'package:baobabe_0_2/core/animation/animated_count.dart';
import 'package:baobabe_0_2/core/animation/fade_swap.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/core/widgets/custom_search_field.dart';
import 'package:baobabe_0_2/core/widgets/offer_card.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/offers_search_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/explore_filters_sheet.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'all_offers_results.dart';

/// « Toutes les offres » : la grille des offres, avec sa recherche et ses
/// filtres — prix, mode de retrait, note, tri.
///
/// Destination de « Offres du moment · Voir tout ». L'accueil ne garde
/// qu'un rail d'offres, Explorer n'en montre plus : c'est ici que l'annuaire
/// entier des offres continue d'exister. Le cubit est créé par la page et
/// meurt avec elle — ce qu'on y tape ne doit pas resurgir dans Explorer.
///
/// La catégorie affichée à l'accueil arrive par la route, pour que la page
/// corresponde exactement à ce que l'utilisateur voyait.
class AllOffersScreen extends StatelessWidget {
  const AllOffersScreen({super.key, this.categorySlug});

  final String? categorySlug;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OffersSearchCubit(categorySlug: categorySlug)..start(),
      child: const _AllOffersBody(),
    );
  }
}

class _AllOffersBody extends StatefulWidget {
  const _AllOffersBody();

  @override
  State<_AllOffersBody> createState() => _AllOffersBodyState();
}

class _AllOffersBodyState extends State<_AllOffersBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  late final OffersSearchCubit _cubit;

  /// Deux colonnes, dans les proportions du rail de l'accueil (190 x 285).
  static const double _cardRatio = 0.67;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OffersSearchCubit>();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      _cubit.loadMore();
    }
  }

  Future<void> _openFilters() async {
    final chosen = await showExploreFiltersSheet(context, _cubit.state.filters);
    if (chosen == null) return;
    await _cubit.filtersChanged(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: AppDimens.headerTopGap),
            Padding(
              padding: AppDimens.appPadding,
              child: Row(
                children: [
                  CustomIconButton(
                    onPressed: () => context.pop(),
                    tooltip: 'Revenir en arrière',
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconSize: 18,
                  ),
                  const SizedBox(width: AppDimens.small),
                  Expanded(
                    child: CustomSearchField(
                      controller: _controller,
                      hint: 'Une offre, un plat, un service…',
                      onChanged: _cubit.queryChanged,
                    ),
                  ),
                  const SizedBox(width: AppDimens.medium),
                  BlocBuilder<OffersSearchCubit, OffersSearchState>(
                    buildWhen: (a, b) =>
                        a.filters.facetCount != b.filters.facetCount,
                    builder: (context, state) => Badge(
                      // La pastille dit combien de critères sont posés :
                      // sans elle, un filtre actif est invisible une fois
                      // la feuille refermée.
                      isLabelVisible: state.filters.facetCount > 0,
                      label: AnimatedCount(value: state.filters.facetCount),
                      child: CustomIconButton(
                        onPressed: _openFilters,
                        tooltip: 'Filtrer les offres',
                        assetPath: 'assets/icons/filter.svg',
                        tone: IconButtonTone.filled,
                        iconSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppDimens.spacerSmall,
            BlocBuilder<OffersSearchCubit, OffersSearchState>(
              buildWhen: (a, b) =>
                  a.filters.categorySlug != b.filters.categorySlug,
              builder: (context, state) => CategoryIcons(
                collapseProgress: 1,
                selectedSlug: state.filters.categorySlug ?? 'all',
                onCategorySelected: _cubit.categorySelected,
              ),
            ),
            AppDimens.spacerSmall,
            Expanded(
              child: BlocBuilder<OffersSearchCubit, OffersSearchState>(
                builder: (context, state) => FadeSwap(
                  child: _OfferResults(
                    state: state,
                    scroll: _scroll,
                    ratio: _cardRatio,
                    onRetry: _cubit.retry,
                    onClearFilters: _cubit.clearFacets,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
