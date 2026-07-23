import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_promo_carouselView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Partie "données" du carrousel promo : branchée sur le même
/// [BusinessBloc]/[CategoryBloc] que [BusinessCardsWidget], filtre la
/// liste, puis délègue tout l'affichage à [BusinessPromoCarouselView].
///
/// Par défaut (sans `filter` personnalisé), affiche uniquement les
/// business **nouveaux** (créés il y a moins de 30 jours).
/// Le badge "Nouveau" est affiché dynamiquement selon la date de
/// création via [UIBusiness.isNew].
class BusinessPromoCarousel extends StatelessWidget {
  final bool Function(dynamic business)? filter;
  final String Function(UIBusiness uiBusiness)? badgeLabelBuilder;
  final String? Function(UIBusiness uiBusiness)? subtitleBuilder;
  final void Function(UIBusiness uiBusiness)? onCardTap;
  final double cardHeight;
  final double viewportFraction;

  const BusinessPromoCarousel({
    super.key,
    this.filter,
    this.badgeLabelBuilder,
    this.subtitleBuilder,
    this.onCardTap,
    this.cardHeight = 200,
    this.viewportFraction = 0.86,
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
            // Section secondaire : rien à afficher en loading/erreur pour
            // éviter de dupliquer le spinner/message déjà montré par
            // BusinessCardsWidget sur la même page.
            if (state is! BusinessLoaded) return const SizedBox.shrink();

            // Filtre par défaut : uniquement les nouveaux (< 30 jours)
            final filtered = filter != null
                ? state.businesses.where(filter!).toList()
                : state.businesses.where((b) {
                    final ui = UIBusiness(b);
                    return ui.isNew;
                  }).toList();

            final uiBusinesses = filtered.map((b) => UIBusiness(b)).toList();

            // Si aucun nouveau business, on cache complètement la section
            if (uiBusinesses.isEmpty) return const SizedBox.shrink();

            return BusinessPromoCarouselView(
              title: 'Nouveautés',
              uiBusinesses: uiBusinesses,
              badgeLabelBuilder: badgeLabelBuilder ?? ((ui) => 'Nouveau'),
              subtitleBuilder: subtitleBuilder,
              onCardTap: onCardTap,
              cardHeight: cardHeight,
              viewportFraction: viewportFraction,
            );
          },
        );
      },
    );
  }
}
