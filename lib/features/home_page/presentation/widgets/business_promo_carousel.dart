import 'package:baobabe_0_2/features/home_page/data/models/ui_business.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/business_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/bloc/category_bloc.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/business_promo_carouselView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Partie "données" du carrousel promo : affiche
/// [BusinessLoaded.newBusinesses], c'est-à-dire les établissements récents
/// **de la catégorie sélectionnée**, déjà filtrés par date et triés par
/// l'Edge Function `get-home`. Délègue tout l'affichage à
/// [BusinessPromoCarouselView].
///
/// Le paramètre [filter] permet à un appelant de restreindre encore la
/// liste reçue (cas particuliers), mais le filtrage "nouveauté" par défaut
/// est fait côté serveur — plus dans le Dart.
class BusinessPromoCarousel extends StatelessWidget {
  final bool Function(dynamic business)? filter;
  final String Function(UIBusiness uiBusiness)? badgeLabelBuilder;
  final String? Function(UIBusiness uiBusiness)? subtitleBuilder;
  final void Function(UIBusiness uiBusiness)? onCardTap;

  /// Card height. Leave null to size responsively — see
  /// [BusinessPromoCarouselView.cardHeight].
  final double? cardHeight;
  final double viewportFraction;

  const BusinessPromoCarousel({
    super.key,
    this.filter,
    this.badgeLabelBuilder,
    this.subtitleBuilder,
    this.onCardTap,
    this.cardHeight,
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
              return previous.newBusinesses != current.newBusinesses;
            }
            return false;
          },
          builder: (context, state) {
            // Section secondaire : rien à afficher en loading/erreur pour
            // éviter de dupliquer le spinner/message déjà montré par
            // BusinessCardsWidget sur la même page.
            if (state is! BusinessLoaded) return const SizedBox.shrink();

            // La sélection "nouveauté" vient du serveur ; `filter` ne sert
            // qu'à restreindre davantage si un appelant le demande.
            final filtered = filter != null
                ? state.newBusinesses.where(filter!).toList()
                : state.newBusinesses;

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
