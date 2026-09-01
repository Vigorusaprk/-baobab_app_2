import 'package:baobabe_0_2/core/animation/appear.dart';
import 'package:baobabe_0_2/core/animation/fade_swap.dart';
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
import 'package:baobabe_0_2/core/widgets/custom_search_field.dart';
import 'package:baobabe_0_2/core/widgets/custom_app_bar.dart';
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
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.categorySlug ?? _allSlug;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          // Le titre suit la catégorie choisie : il vient d'un BlocBuilder,
          // pas d'une chaîne. D'où `CustomAppBar`, qui prend un widget, plutôt
          // que `CustomOtherAppBar`, qui prend un texte.
          appBar: CustomAppBar(
            isCenter: true,
            widget: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) => Text(
                Category.displayNameForSlug(
                  _selected,
                  categoryState is CategoriesLoaded
                      ? categoryState.categories
                      : Category.fallback,
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          body: Column(
            children: [
              AppDimens.spacerSmall,
              // Le champ partagé, en saisie directe : il cherche **ici**.
              // L'écran empruntait la barre de l'accueil, devenue une simple
              // porte vers Explorer — taper dedans quittait donc la page. Et
              // Explorer cherche des offres, pas des commerces : le bouton de
              // filtres qui l'accompagnait n'avait rien à faire ici non plus.
              Padding(
                padding: AppDimens.appPadding,
                child: CustomSearchField(
                  controller: _search,
                  hint: 'Rechercher un commerce…',
                  onChanged: context.read<BusinessListCubit>().queryChanged,
                ),
              ),
              AppDimens.spacerSmall,
              // Bande compacte, comme sur Explorer : cet écran défile
              // longuement, une bande haute mangerait la place de la liste.
              CategoryIcons(
                collapseProgress: 1,
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
                    // Le contenu se croise au lieu de sauter : c'est le même
                    // bloc qui change d'état, pas un écran qui en remplace un
                    // autre.
                    return FadeSwap(child: _content(context, state));
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

/// Ce que la zone de liste montre, selon l'état. Chaque cas porte sa propre
/// clé : sans elle, [FadeSwap] croirait qu'il s'agit du même contenu et ne
/// croiserait rien.
Widget _content(BuildContext context, BusinessListState state) {
  if (state.isLoading)
    return const _LoadingSkeleton(key: ValueKey('squelette'));

  if (state.errorMessage != null) {
    return _ErrorView(
      key: const ValueKey('echec'),
      message: state.errorMessage!,
      onRetry: () => context.read<BusinessListCubit>().load(state.category),
    );
  }

  if (state.businesses.isEmpty) return const _EmptyView(key: ValueKey('vide'));

  return _BusinessList(key: const ValueKey('liste'), state: state);
}

/// Marges communes à la liste et à son squelette, pour qu'ils se
/// superposent exactement au moment du basculement.
///
/// L'horizontale reprend `appPaddingValue`, comme le champ de recherche et la
/// bande de catégories au-dessus : elle valait `large` (24), et la liste était
/// donc décalée de 8 px vers l'intérieur par rapport à tout ce qui la
/// surmontait.
///
/// La marge basse dégage la barre de navigation flottante. Elle vaut la cible
/// tactile plus deux respirations, au lieu du 100 en dur qui ne correspondait
/// à la hauteur de rien.
const EdgeInsets _listPadding = EdgeInsets.fromLTRB(
  AppDimens.appPaddingValue,
  AppDimens.small,
  AppDimens.appPaddingValue,
  AppDimens.touchTarget + AppDimens.large * 2,
);

class _BusinessList extends StatelessWidget {
  final BusinessListState state;

  const _BusinessList({super.key, required this.state});

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
          return Appear(
            index: index,
            child: BusinessListRow(
              uiBusiness: uiBusiness,
              onTap: () => context.pushNamed(
                'businessDetail',
                pathParameters: {'id': uiBusiness.business.id},
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({super.key});

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
  const _EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 60,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          AppDimens.spacerMedium,
          Text(
            'Aucun commerce dans cette catégorie',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimens.appPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Theme.of(context).colorScheme.error,
            ),
            AppDimens.spacerMedium,
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            AppDimens.spacerMedium,
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
