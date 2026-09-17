import 'package:baobabe_0_2/core/animation/animated_count.dart';
import 'package:baobabe_0_2/core/animation/fade_swap.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/business_card.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/core/widgets/custom_search_field.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_filters_sheet.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_sections.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/search_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'search_page_results.dart';

/// Explorer : l'annuaire des **commerces**.
///
/// C'est ce que la plateforme met en avant, et c'est tout ce que l'onglet
/// montre — « Voir tout » des mieux notés arrive ici aussi. Les offres ont
/// leur propre page, « Toutes les offres », derrière l'accueil.
///
/// Les critères d'un commerce — ouvert maintenant, on peut y commander, y
/// réserver, y passer — vivent dans la feuille qu'ouvre le bouton de filtres,
/// comme partout ailleurs. En rangée de puces sous le champ, ils
/// surchargeaient l'écran avant même le premier résultat.
///
/// La bande de catégories reste en permanence dans son état réduit : ici elle
/// accompagne une grille qu'on fait défiler longuement, et une bande haute
/// mangerait la place des résultats.
class SearchPageBody extends StatefulWidget {
  const SearchPageBody({super.key});

  @override
  State<SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<SearchPageBody> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final GlobalKey _searchFieldKey = GlobalKey();
  final ScrollController _scroll = ScrollController();
  late final ExploreCubit _explore;

  @override
  void initState() {
    super.initState();
    _explore = context.read<ExploreCubit>()..start();
    _scroll.addListener(_onScroll);

    // L'intention est posée par l'accueil **avant** que cet écran existe :
    // au premier passage, l'`IndexedStack` du shell ne l'a pas encore
    // construit. Un `BlocListener` ne se déclenche pas pour l'état déjà là
    // quand il s'abonne — il ne voit que les transitions suivantes. Il faut
    // donc aussi regarder ce qui est en attente à l'ouverture.
    _handleIntent(_explore.state.pendingIntent);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocus.dispose();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  /// Exécute ce que l'accueil a demandé en nous envoyant ici, puis le
  /// consomme pour que ça ne se rejoue pas au prochain retour sur l'onglet.
  void _handleIntent(ExploreIntent? intent) {
    if (intent == null) return;
    _explore.intentHandled();
    switch (intent) {
      case ExploreIntent.openFilters:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openFilters();
        });
      case ExploreIntent.focusSearch:
        _focusWhenVisible();
    }
  }

  /// Donne le focus au champ dès qu'Explorer est réellement à l'écran.
  ///
  /// Toucher la barre de l'accueil, c'est vouloir taper : le clavier doit
  /// être là à l'arrivée, sans second geste.
  ///
  /// La difficulté tient à l'`IndexedStack` du shell : les quatre onglets
  /// restent montés, et celui qu'on ne voit pas est hors écran. Un champ hors
  /// écran ne peut pas prendre le focus — la demande est simplement ignorée,
  /// sans erreur. Et la bascule d'onglet ne prend pas effet dans la trame qui
  /// suit l'appel de route, mais quelques trames plus tard.
  ///
  /// On réessaie donc jusqu'à ce que le champ soit visible, en abandonnant au
  /// bout de quelques essais plutôt que de boucler : si l'utilisateur a
  /// changé d'avis entre-temps, lui ouvrir le clavier serait pire que rien.
  void _focusWhenVisible({int attempts = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final visible =
          _searchFieldKey.currentContext?.findRenderObject()?.attached ?? false;
      if (visible && ModalRoute.of(context)?.isCurrent != false) {
        _searchFocus.requestFocus();
        return;
      }
      if (attempts < 10) {
        Future.delayed(
          const Duration(milliseconds: 50),
          () => _focusWhenVisible(attempts: attempts + 1),
        );
      }
    });
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      _explore.loadMore();
    }
  }

  Future<void> _openFilters() async {
    final chosen = await showBusinessFiltersSheet(
      context,
      _explore.state.filters,
    );
    if (chosen == null) return;
    await _explore.filtersChanged(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Le même blanc que l'accueil, au-dessus de la barre de
            // recherche : `SafeArea` ne réserve que la hauteur de la barre
            // d'état, et le champ se retrouvait collé au bord.
            const SizedBox(height: AppDimens.headerTopGap),
            _SearchRow(
              key: _searchFieldKey,
              controller: _controller,
              focusNode: _searchFocus,
              onChanged: _explore.queryChanged,
              onFilters: _openFilters,
            ),
            AppDimens.spacerSmall,
            BlocBuilder<ExploreCubit, ExploreState>(
              buildWhen: (a, b) =>
                  a.filters.categorySlug != b.filters.categorySlug,
              builder: (context, state) => CategoryIcons(
                collapseProgress: 1,
                selectedSlug: state.filters.categorySlug ?? 'all',
                onCategorySelected: _explore.categorySelected,
              ),
            ),
            AppDimens.spacerSmall,
            Expanded(
              child: BlocConsumer<ExploreCubit, ExploreState>(
                listenWhen: (a, b) =>
                    a.pendingIntent == null && b.pendingIntent != null,
                // Pour le cas où l'écran est déjà monté : l'utilisateur
                // revient sur l'accueil et retouche la barre.
                listener: (context, state) =>
                    _handleIntent(state.pendingIntent),
                builder: (context, state) => FadeSwap(
                  child: _BusinessResults(
                    state: state,
                    scroll: _scroll,
                    onRetry: _explore.retry,
                    onClearFilters: _explore.clearFacets,
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

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.appPadding,
      child: Row(
        children: [
          Expanded(
            child: CustomSearchField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: AppDimens.medium),
          BlocBuilder<ExploreCubit, ExploreState>(
            buildWhen: (a, b) => a.filters.facetCount != b.filters.facetCount,
            builder: (context, state) => Badge(
              // La pastille dit combien de critères sont posés : sans elle,
              // un filtre actif est invisible une fois la feuille refermée.
              isLabelVisible: state.filters.facetCount > 0,
              // Le compte défile au lieu de sauter : on voit qu'il a bougé,
              // et dans quel sens.
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
}
