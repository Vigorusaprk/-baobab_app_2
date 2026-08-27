import 'package:baobabe_0_2/core/widgets/see_all.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_list_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Partie "vue" pure de la section Populaires : reçoit une liste déjà
/// prête de [UIBusiness] et affiche l'en-tête + les lignes.
///
/// Ne dépend d'aucun Bloc — réutilisable ailleurs (ex: écran de
/// recherche par catégorie) si besoin d'afficher ce même style de
/// liste sans passer par BusinessBloc.
///
/// ⚠️ Pas de distance affichée : la table `business` n'a pas encore de
/// colonnes `latitude`/`longitude` côté Supabase. Dès qu'elles
/// existeront, on pourra ajouter un `distanceBuilder` sur ce widget.
class PopularBusinessListView extends StatelessWidget {
  final List<UIBusiness> uiBusinesses;
  final String title;
  final VoidCallback? onSeeAllTap;
  final void Function(UIBusiness uiBusiness)? onItemTap;

  const PopularBusinessListView({
    super.key,
    required this.uiBusinesses,
    this.title = 'Populaires',
    this.onSeeAllTap,
    this.onItemTap,
  });

  void _handleTap(BuildContext context, UIBusiness uiBusiness) {
    if (onItemTap != null) {
      onItemTap!(uiBusiness);
      return;
    }
    context.pushNamed(
      'businessDetail',
      pathParameters: {'id': uiBusiness.business.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (uiBusinesses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            SeeAll(
              onTap: onSeeAllTap,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...uiBusinesses.map(
          (uiBusiness) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BusinessListRow(
              uiBusiness: uiBusiness,
              onTap: () => _handleTap(context, uiBusiness),
            ),
          ),
        ),
      ],
    );
  }
}
