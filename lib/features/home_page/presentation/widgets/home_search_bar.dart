import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/core/widgets/button/custom_icon_button.dart';
import 'package:baobabe_0_2/core/widgets/custom_search_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// La barre de recherche de l'accueil.
///
/// Le champ n'est qu'une porte : il emmène sur Explorer, qui porte la vraie
/// recherche. Il garde pourtant exactement l'habillage du champ d'Explorer
/// ([CustomSearchField]) — c'est le même geste des deux côtés.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  /// Hauteur intrinsèque de la barre, reprise de [CustomSearchField].
  ///
  /// Exposée pour que [HomeSliverHeader], qui doit déclarer des extents
  /// fixes, réserve exactement la bonne place.
  static const double height = CustomSearchField.height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimens.appPadding,
      child: Row(
        children: [
          Expanded(
            child: CustomSearchField(
              readOnly: true,
              onTap: () => context.pushNamed('search'),
            ),
          ),
          const SizedBox(width: AppDimens.medium),
          CustomIconButton(
            onPressed: () => context.pushNamed('budgetFinder'),
            tooltip: 'Trouver selon mon budget',
            assetPath: 'assets/icons/filter.svg',
            tone: IconButtonTone.filled,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
