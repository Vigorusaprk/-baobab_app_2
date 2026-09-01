import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_search_field.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/explore_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// La barre de recherche de l'accueil.
///
/// Ni le champ ni le bouton ne portent de recherche : **les deux emmènent sur
/// Explorer**, qui la porte. Le champ y va simplement, le bouton y va avec le
/// panneau de filtres déjà ouvert.
///
/// L'accueil renvoyait auparavant vers une page `/search` autonome, doublon de
/// l'onglet Explorer, et son bouton vers un « Trouver selon mon budget »
/// séparé. Trois écrans pour une même question. Il n'en reste qu'un.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  /// Hauteur intrinsèque de la barre, reprise de [CustomSearchField].
  ///
  /// Exposée pour que [HomeSliverHeader], qui doit déclarer des extents
  /// fixes, réserve exactement la bonne place.
  static const double height = CustomSearchField.height;

  void _goToExplore(BuildContext context, {required ExploreIntent intent}) {
    final cubit = context.read<ExploreCubit>();

    // **On change d'onglet d'abord.** Explorer vit dans un `IndexedStack` et
    // reste donc monté même caché : demander avant de naviguer faisait
    // consommer l'intention par un écran encore masqué, et le clavier ne
    // s'ouvrait pas.
    context.goNamed('expolre');

    // La demande passe par le cubit et non par la route : un paramètre d'URL
    // serait resté après coup, et aurait rejoué l'action à chaque retour sur
    // l'onglet.
    switch (intent) {
      case ExploreIntent.openFilters:
        cubit.requestFilters();
      case ExploreIntent.focusSearch:
        cubit.requestSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.appPadding,
      child: Row(
        children: [
          Expanded(
            child: CustomSearchField(
              readOnly: true,
              onTap: () =>
                  _goToExplore(context, intent: ExploreIntent.focusSearch),
            ),
          ),
          const SizedBox(width: AppDimens.medium),
          CustomIconButton(
            onPressed: () =>
                _goToExplore(context, intent: ExploreIntent.openFilters),
            tooltip: 'Filtrer les offres',
            assetPath: 'assets/icons/filter.svg',
            tone: IconButtonTone.filled,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
