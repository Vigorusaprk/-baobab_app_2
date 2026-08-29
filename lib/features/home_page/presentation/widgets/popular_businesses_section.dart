import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/popular_business_listView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Partie "données" de la section Populaires : affiche
/// [BusinessLoaded.popularBusinesses], c'est-à-dire les mieux notés **de la
/// catégorie sélectionnée**, déjà triés et tronqués par l'Edge Function
/// `get-home`. Rien n'est trié ni filtré ici : changer de catégorie
/// recharge la liste côté serveur.
///
/// ⚠️ Pas de vrai critère "popularité" dédié côté base pour l'instant
/// (pas de compteur de vues/commandes) — le tri par `rating` est une
/// approximation raisonnable en attendant mieux.
class PopularBusinessesSection extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;
  final void Function(UIBusiness uiBusiness)? onItemTap;

  const PopularBusinessesSection({
    super.key,
    this.title = 'Commerces populaires',
    this.onSeeAllTap,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        return BlocBuilder<BusinessBloc, BusinessState>(
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) return true;
            if (current is BusinessLoaded && previous is BusinessLoaded) {
              return previous.popularBusinesses != current.popularBusinesses;
            }
            return false;
          },
          builder: (context, state) {
            if (state is! BusinessLoaded) return const SizedBox.shrink();

            final uiBusinesses = state.popularBusinesses
                .map((b) => UIBusiness(b))
                .toList();

            return Padding(
              padding: AppDimens.appPadding,
              child: PopularBusinessListView(
                uiBusinesses: uiBusinesses,
                title: title,
                onSeeAllTap: onSeeAllTap,
                onItemTap: onItemTap,
              ),
            );
          },
        );
      },
    );
  }
}
