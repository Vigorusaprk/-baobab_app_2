import 'package:baobabe_0_2/core/themes/app_colors.dart';
import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_remote_datasource_impl.dart';
import 'package:baobabe_0_2/features/home_page/data/repositories/business_repository_impl.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/domain/entities/category_entity.dart';
import 'package:baobabe_0_2/features/home_page/domain/usecases/get_businesses_page.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_list_cubit.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/Category_Icons.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_list_row.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/home_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Destination du lien "Voir tout" des sections "Populaires" et
/// "Découvrir" de l'accueil.
///
/// Ces deux sections montrent le même classement (note décroissante, puis
/// nombre d'avis) : "Populaires" en est le podium, "Découvrir" le
/// carrousel. "Voir tout" déroule donc la liste complète, dans le même
/// ordre, et permet d'en changer la catégorie sur place.
///
/// La sélection de catégorie est **locale à cet écran** : elle ne passe pas
/// par le `CategoryBloc` global, sinon revenir à l'accueil laisserait une
/// puce sélectionnée ne correspondant pas au contenu affiché en dessous.
class AllBusinessesScreen extends StatefulWidget {
  /// Slug de la catégorie initialement affichée, repris de l'accueil.
  final String? categorySlug;

  const AllBusinessesScreen({super.key, this.categorySlug});

  /// Nombre d'éléments du squelette de chargement.
  static const int _skeletonItemCount = 6;

  @override
  State<AllBusinessesScreen> createState() => _AllBusinessesScreenState();
}

class _AllBusinessesScreenState extends State<AllBusinessesScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.categorySlug ?? _allSlug;
  }

  static const String _allSlug = 'all';

  /// Paramètre envoyé au serveur : "Tout" ne filtre rien.
  static String? _categoryParam(String slug) =>
      (slug.isEmpty || slug == _allSlug || slug == 'other') ? null : slug;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = BusinessRepositoryImpl(
          remoteDataSource: BusinessRemoteDataSourceImpl(),
        );
        return BusinessListCubit(
          getBusinessesPage: GetBusinessesPage(repository),
        )..load(_categoryParam(_selected));
      },
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) => Text(
                Category.displayNameForSlug(
                  _selected,
                  categoryState is CategoriesLoaded
                      ? categoryState.categories
                      : Category.fallback,
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: Column(
            children: [
              AppDimens.spacerSmall,
              const HomeSearchBar(),
              AppDimens.spacerSmall,
              CategoryIcons(
                selectedSlug: _selected,
                onCategorySelected: (slug) {
                  if (slug == _selected) return;
                  setState(() => _selected = slug);
                  context.read<BusinessListCubit>().load(_categoryParam(slug));
                },
              ),
              AppDimens.spacerSmall,
              Expanded(
                child: BlocBuilder<BusinessListCubit, BusinessListState>(
                  builder: (context, state) {
                    if (state.isLoading) return const _LoadingSkeleton();

                    if (state.errorMessage != null) {
                      return _ErrorView(
                        message: state.errorMessage!,
                        onRetry: () => context.read<BusinessListCubit>().load(
                          _categoryParam(_selected),
                        ),
                      );
                    }

                    if (state.businesses.isEmpty) return const _EmptyView();

                    return _BusinessList(state: state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Marges communes à la liste et à son squelette, pour qu'ils se
/// superposent exactement au moment du basculement.
const EdgeInsets _listPadding = EdgeInsets.fromLTRB(
  AppDimens.large,
  AppDimens.small,
  AppDimens.large,
  100,
);

class _BusinessList extends StatelessWidget {
  final BusinessListState state;

  const _BusinessList({required this.state});

  @override
  Widget build(BuildContext context) {
    // Une ligne supplémentaire en fin de liste pendant qu'une page se
    // charge : elle affiche le squelette de la vraie ligne, comme sur
    // l'accueil, plutôt qu'un indicateur circulaire.
    final itemCount = state.businesses.length + (state.isLoadingMore ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () => context.read<BusinessListCubit>().load(state.category),
      child: ListView.separated(
        padding: _listPadding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= state.businesses.length) {
            return const Skeletonizer(
              enabled: true,
              child: BusinessListRowSkeleton(),
            );
          }

          // Scroll infini : la vue signale seulement qu'elle approche de la
          // fin. Page suivante, hasMore et anti-doublon vivent dans le
          // cubit — elle ne sait rien de la pagination.
          if (index == state.businesses.length - 2) {
            context.read<BusinessListCubit>().loadMore();
          }

          final uiBusiness = UIBusiness(state.businesses[index]);
          return BusinessListRow(
            uiBusiness: uiBusiness,
            onTap: () => context.pushNamed(
              'businessDetail',
              pathParameters: {'id': uiBusiness.business.id},
            ),
          );
        },
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: _listPadding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: AllBusinessesScreen._skeletonItemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => const BusinessListRowSkeleton(),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.business_outlined,
            size: 60,
            color: AppColors.textSecondary,
          ),
          AppDimens.spacerMedium,
          Text(
            'Aucun établissement dans cette catégorie',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimens.appPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppColors.errorContent),
            AppDimens.spacerMedium,
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.errorContent),
            ),
            AppDimens.spacerMedium,
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
