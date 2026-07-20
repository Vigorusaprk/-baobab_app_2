import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/popular_business_listView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Partie "données" de la section Populaires : branchée sur le même
/// [BusinessBloc]/[CategoryBloc] que [BusinessCardsWidget] et
/// [BusinessPromoCarousel], trie par note décroissante (puis nombre
/// d'avis en cas d'égalité), garde les `maxItems` premiers, puis
/// délègue l'affichage à [PopularBusinessListView].
///
/// ⚠️ Pas de vrai critère "popularité" dédié côté base pour l'instant
/// (pas de compteur de vues/commandes) — le tri par `rating` est une
/// approximation raisonnable en attendant mieux.
class PopularBusinessesSection extends StatelessWidget {
  final int maxItems;
  final String title;
  final VoidCallback? onSeeAllTap;
  final void Function(UIBusiness uiBusiness)? onItemTap;

  const PopularBusinessesSection({
    super.key,
    this.maxItems = 5,
    this.title = 'Populaires',
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
              return previous.businesses != current.businesses;
            }
            return false;
          },
          builder: (context, state) {
            if (state is! BusinessLoaded) return const SizedBox.shrink();

            final sorted = [...state.businesses]..sort((a, b) {
              final ratingCompare = b.rating.compareTo(a.rating);
              if (ratingCompare != 0) return ratingCompare;
              return b.reviewCount.compareTo(a.reviewCount);
            });

            final top = sorted.take(maxItems).toList();
            final uiBusinesses = top.map((b) => UIBusiness(b)).toList();

            return Padding(
              padding: const EdgeInsets.only(
                left: AppDimens.PADDING_20,
                right: AppDimens.PADDING_20,
                top: AppDimens.PADDING_16,
              ),
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