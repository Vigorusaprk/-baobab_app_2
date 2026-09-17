import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_offers_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_home_feed.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_skeleton.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_sliver_header.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';

/// Body-only content for the Home tab. The Scaffold is owned by MainShell.
///
/// Cet écran n'a pas d'AppBar : [HomeSliverHeader] joue ce rôle. Il défile
/// avec la page tant qu'on est en haut, puis reste épinglé sous forme
/// compacte — c'est lui qui occupe la place de la barre d'application.
/// Le scroll est aimanté pour que l'en-tête se stabilise toujours sur l'un
/// de ses deux états, jamais à mi-transformation (voir [_snapHeader]).
class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final ScrollController _scrollController = ScrollController();

  static const Duration _snapDuration = Duration(milliseconds: 180);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Aimante l'en-tête sur l'un de ses deux états stables.
  ///
  /// Le repliement est une interpolation continue : à mi-course, la
  /// vignette de catégorie n'est ni une colonne ni une ligne, et s'y
  /// arrêter donne un rendu bancal. Plutôt que de compliquer la
  /// transformation pour rendre présentable un état qui n'a pas vocation à
  /// durer, on empêche le scroll de s'y immobiliser : au relâchement, on
  /// rejoint l'état le plus proche.
  bool _snapHeader(ScrollEndNotification notification) {
    // Seul le défilement vertical de la page nous intéresse : les listes
    // horizontales imbriquées (catégories, carrousels) remontent leurs
    // propres notifications avec une profondeur supérieure.
    if (notification.depth != 0) return false;

    final range = HomeSliverHeaderMetrics.collapseRange(context);
    final offset = notification.metrics.pixels;
    if (offset <= 0 || offset >= range) return false;

    final target = offset < range / 2 ? 0.0 : range;

    // On ne peut pas modifier la position pendant la notification elle-même.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        target,
        duration: _snapDuration,
        curve: Curves.easeOut,
      );
    });
    return false;
  }

  /// La catégorie affichée à l'accueil, pour que la page où l'on va
  /// corresponde exactement à ce que l'utilisateur voyait.
  String _currentSlug(BuildContext context) {
    final state = context.read<BusinessBloc>().state;
    return state is BusinessLoaded ? state.currentSlug : BusinessBloc.allSlug;
  }

  /// « Offres du moment · Voir tout » : la page « Toutes les offres », avec
  /// sa recherche et ses filtres, dans la catégorie affichée.
  void _openOffers(BuildContext context) {
    context.pushNamed(
      'allOffers',
      extra: {'categorySlug': _currentSlug(context)},
    );
  }

  /// « Les mieux notés · Voir tout » : Explorer, qui montre **tous** les
  /// commerces, dans la catégorie affichée. L'onglet existe déjà, on ne
  /// pousse pas une page par-dessus le shell — l'ancienne page « Tous les
  /// commerces » en était le doublon.
  void _openAllBusinesses(BuildContext context) {
    context.read<ExploreCubit>().categorySelected(_currentSlug(context));
    context.goNamed('expolre');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final repository = BusinessRepositoryImpl(
              remoteDataSource: BusinessRemoteDataSourceImpl(),
            );
            return BusinessBloc(
              getHomeFeed: GetHomeFeed(repository),
              getOffersPage: GetOffersPage(repository),
            )..add(LoadBusinesses());
          },
        ),
      ],
      // Pas de `buildWhen` ici. Il y en avait un — « reconstruire seulement
      // si le type de l'état change » — et il figeait l'accueil sur son
      // premier état chargé : ajouter des offres produit un `BusinessLoaded`
      // après un autre `BusinessLoaded`, donc aucun rafraîchissement. Les
      // deux paginations chargeaient sans jamais rien montrer.
      //
      // Filtrer n'est pas nécessaire : `BusinessState` est un Equatable, et
      // un bloc n'émet pas deux états égaux à la suite. Un état identique ne
      // reconstruit donc rien de toute façon.
      child: BlocBuilder<BusinessBloc, BusinessState>(
        builder: (context, state) {
          final isLoading =
              state is BusinessInitial || state is BusinessLoading;

          return CustomRefresh(
            onRefresh: () {
              final bloc = context.read<BusinessBloc>();
              bloc.add(LoadBusinesses());
              return awaitSettled<BusinessState>(
                bloc.stream,
                (s) => s is BusinessLoaded || s is BusinessError,
              );
            },
            child: NotificationListener<ScrollEndNotification>(
              onNotification: _snapHeader,
              child: CustomScrollView(
                controller: _scrollController,
                physics: isLoading
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Recherche + catégories : toujours montées, y compris
                  // pendant le chargement. Leur contenu ne dépend d'aucune
                  // requête, et changer de catégorie déclenche désormais un
                  // appel réseau — la puce qu'on vient de taper doit rester
                  // visible.
                  const HomeSliverHeader(),
                  SliverToBoxAdapter(
                    child: isLoading
                        ? const Skeletonizer(
                            enabled: true,
                            child: HomeSkeleton(),
                          )
                        : _Sections(
                            state: state,
                            onSeeAllBusinesses: () =>
                                _openAllBusinesses(context),
                            onSeeAllOffers: () => _openOffers(context),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Les sections de l'accueil. Il met en avant des **commerçants** : à la
/// une, nouveaux, les mieux notés. Les offres n'y gardent qu'un rail en bas
/// et ont leur page — Explorer, mode Offres.
class _Sections extends StatelessWidget {
  final BusinessState state;
  final VoidCallback onSeeAllBusinesses;
  final VoidCallback onSeeAllOffers;

  const _Sections({
    required this.state,
    required this.onSeeAllBusinesses,
    required this.onSeeAllOffers,
  });

  @override
  Widget build(BuildContext context) {
    if (state is! BusinessLoaded) return const SizedBox.shrink();
    final loaded = state as BusinessLoaded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section à part, en tête : les commerçants en campagne.
        FeaturedBusinessesSection(featured: loaded.featuredBusinesses),
        if (loaded.featuredBusinesses.isNotEmpty) AppDimens.spacerMedium,
        BusinessRail(
          title: 'Nouveaux sur Baobabe',
          subtitle: "Ils viennent d'ouvrir leurs portes.",
          businesses: loaded.newBusinesses,
          width: RailWidth.wide,
        ),
        if (loaded.newBusinesses.isNotEmpty) AppDimens.spacerMedium,
        BusinessGrid(
          title: 'Les mieux notés',
          businesses: loaded.popularBusinesses,
          onSeeAll: onSeeAllBusinesses,
        ),
        if (loaded.popularBusinesses.isNotEmpty) AppDimens.spacerMedium,
        // Un seul rail d'offres, en bas : moins de place, pas zéro.
        OffersCarouselSection(
          title: 'Offres du moment',
          offers: loaded.newOffers,
          hasMore: true,
          onSeeMore: onSeeAllOffers,
          onSeeAll: onSeeAllOffers,
        ),
      ],
    );
  }
}
