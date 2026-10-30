import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/core/widgets/custom_refresh.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_home_feed.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_offers_page.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_page_feed_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Corps de l'onglet Accueil; le shell fournit le Scaffold.
/// La vue défilante garde son en-tête et son aimantation dédiés.
class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _refresh(BuildContext context) {
    final bloc = context.read<BusinessBloc>();
    bloc.add(LoadBusinesses());
    return awaitSettled<BusinessState>(
      bloc.stream,
      (state) => state is BusinessLoaded || state is BusinessError,
    );
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
      // Les états paginés gardent le même type et doivent tous reconstruire l'accueil.
      child: BlocBuilder<BusinessBloc, BusinessState>(
        builder: (context, state) {
          return HomePageFeedView(
            state: state,
            scrollController: _scrollController,
            onRefresh: () => _refresh(context),
            onSeeAllBusinesses: () => _openAllBusinesses(context),
            onSeeAllOffers: () => _openOffers(context),
          );
        },
      ),
    );
  }
}
