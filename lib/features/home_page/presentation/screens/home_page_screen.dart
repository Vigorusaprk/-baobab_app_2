import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_home_feed.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_cards_widget.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_promo_carousel.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_skeleton.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_sliver_header.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/popular_businesses_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

    const range = HomeSliverHeaderMetrics.collapseRange;
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

  /// Ouvre la liste complete pour la categorie actuellement affichee.
  ///
  /// "Populaires" et "Decouvrir" partagent le meme classement (note, puis
  /// nombre d'avis) : leur "Voir tout" mene donc a la meme liste, filtree
  /// sur la categorie selectionnee pour que la page corresponde a ce que
  /// l'utilisateur avait sous les yeux.
  void _openAllBusinesses(BuildContext context) {
    final state = context.read<BusinessBloc>().state;
    final slug = state is BusinessLoaded
        ? state.currentSlug
        : BusinessBloc.allSlug;

    context.pushNamed('allBusinesses', extra: {'categorySlug': slug});
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
              getBusinessesPage: GetBusinessesPage(repository),
            )..add(LoadBusinesses());
          },
        ),
      ],
      child: BlocBuilder<BusinessBloc, BusinessState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, state) {
          final isLoading = state is BusinessInitial || state is BusinessLoading;

          return NotificationListener<ScrollEndNotification>(
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
                      ? const Skeletonizer(enabled: true, child: HomeSkeleton())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BusinessPromoCarousel(),
                            AppDimens.spacerSmall,
                            PopularBusinessesSection(
                              onSeeAllTap: () => _openAllBusinesses(context),
                            ),
                            AppDimens.spacerSmall,
                            BusinessCardsWidget(
                              onSeeAllTap: () => _openAllBusinesses(context),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
