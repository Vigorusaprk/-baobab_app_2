import 'package:baobabe_0_2/core/animation/animated_count.dart';
import 'package:baobabe_0_2/core/animation/appear.dart';
import 'package:baobabe_0_2/core/animation/fade_swap.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_search_field.dart';
import 'package:baobabe_0_2/core/widgets/offer_card.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/explore_filters_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_action_button.dart';

/// Explorer : toutes les offres, cherchables et filtrables.
///
/// L'écran présentait auparavant des **commerces**, en chargeant les
/// cinquante premiers puis en les filtrant en Dart. Il présente désormais des
/// **offres**, cherchées en base par `get-home?section=discover` — le même
/// objet que les carrousels de l'accueil, dans la même carte.
///
/// La bande de catégories reste en permanence dans son état réduit : ici elle
/// accompagne une grille qu'on fait défiler longuement, et une bande haute
/// mangerait la place des résultats.
class SearchPageBody extends StatefulWidget {
  const SearchPageBody({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<SearchPageBody> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final GlobalKey _searchFieldKey = GlobalKey();
  final ScrollController _scroll = ScrollController();
  late final ExploreCubit _explore;

  /// Deux colonnes, dans les proportions du rail de l'accueil (190 x 285).
  static const double _cardRatio = 0.67;

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
    final chosen = await showExploreFiltersSheet(
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
            AppDimens.spacerSmall,
            _SearchRow(
              key: _searchFieldKey,
              controller: _controller,
              focusNode: _searchFocus,
              showBackButton: widget.showBackButton,
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
                  child: _Results(
                    state: state,
                    scroll: _scroll,
                    ratio: _cardRatio,
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
    required this.showBackButton,
    required this.onChanged,
    required this.onFilters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showBackButton;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.appPadding,
      child: Row(
        children: [
          if (showBackButton) ...[
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              tooltip: 'Revenir en arrière',
              icon: Icons.arrow_back_ios_new_rounded,
              iconSize: 18,
            ),
            const SizedBox(width: AppDimens.small),
          ],
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
              // un filtre actif est invisible une fois le panneau refermé.
              isLabelVisible: state.filters.facetCount > 0,
              // Le compte défile au lieu de sauter : on voit qu'il a bougé,
              // et dans quel sens.
              label: AnimatedCount(value: state.filters.facetCount),
              child: CustomIconButton(
                onPressed: onFilters,
                tooltip: 'Filtrer les offres',
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

class _Results extends StatelessWidget {
  const _Results({
    required this.state,
    required this.scroll,
    required this.ratio,
    required this.onRetry,
    required this.onClearFilters,
  });

  final ExploreState state;
  final ScrollController scroll;
  final double ratio;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (state.status == ExploreStatus.failure) {
      return _Message(
        key: const ValueKey('echec'),
        title: 'La recherche a échoué',
        body: state.message ?? 'Réessayez dans un instant.',
        actionLabel: 'Réessayer',
        onAction: onRetry,
      );
    }

    final loading =
        state.status == ExploreStatus.loading ||
        state.status == ExploreStatus.initial;

    if (loading && state.offers.isEmpty) {
      return Skeletonizer(
        key: const ValueKey('squelette'),
        enabled: true,
        child: GridView.builder(
          padding: AppDimens.appPadding,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: _delegate,
          itemCount: 6,
          itemBuilder: (_, _) => const OfferCardSkeleton(),
        ),
      );
    }

    if (state.offers.isEmpty) {
      return _Message(
        key: const ValueKey('vide'),
        title: 'Aucune offre ne correspond',
        body: state.filters.hasFacets
            ? 'Essayez d\'élargir vos filtres.'
            : 'Essayez un autre mot.',
        actionLabel: state.filters.hasFacets ? 'Effacer les filtres' : null,
        onAction: state.filters.hasFacets ? onClearFilters : null,
      );
    }

    return GridView.builder(
      key: const ValueKey('resultats'),
      controller: scroll,
      padding: AppDimens.appPadding.copyWith(
        top: AppDimens.small,
        bottom: AppDimens.large,
      ),
      gridDelegate: _delegate,
      itemCount: state.offers.length + (state.loadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= state.offers.length) {
          return const Skeletonizer(enabled: true, child: OfferCardSkeleton());
        }
        final offer = state.offers[index];
        return Appear(
          index: index,
          child: OfferCard(
            offer: offer,
            onTap: () => context.pushNamed(
              'offerDetail',
              pathParameters: {'id': offer.id},
            ),
          ),
        );
      },
    );
  }

  SliverGridDelegate get _delegate => SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: ratio,
    mainAxisSpacing: AppDimens.allPadding12Number,
    crossAxisSpacing: AppDimens.allPadding12Number,
  );
}

/// Un état vide ou en échec : ce qui s'est passé, et quoi faire ensuite.
class _Message extends StatelessWidget {
  const _Message({
    super.key,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            AppDimens.spacerSmall,
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              AppDimens.spacerMedium,
              CustomActionButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
