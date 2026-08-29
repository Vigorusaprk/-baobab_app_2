import 'package:baobabe_0_2/core/themes/app_diemens.dart';
import 'package:baobabe_0_2/features/business_detail/domain/entities/offer.dart';
import 'package:baobabe_0_2/features/home_page/presentation/widgets/offers_carousel_section.dart';
import 'package:flutter/material.dart';

/// Le catalogue du commerçant, en carrousels.
///
/// Un carrousel par rayon (Plats, Chambres, Soins…) quand le commerçant en
/// déclare, sinon un seul. C'est la seule porte d'entrée vers l'achat sur
/// cette page : chaque offre mène à sa propre fiche, où l'on commande ou
/// l'on réserve.
///
/// Les offres lui sont **données** : elles arrivent dans la même réponse que
/// le commerce. La section les cherchait elle-même, ce qui doublait l'appel
/// réseau à chaque ouverture de fiche.
class BusinessOffersSection extends StatelessWidget {
  final List<Offer> offers;

  const BusinessOffersSection({super.key, required this.offers});

  /// Regroupe les offres par rayon en conservant l'ordre du serveur : les
  /// offres datées d'abord, puis l'alphabétique.
  Map<String, List<Offer>> get _bySection {
    final grouped = <String, List<Offer>>{};
    for (final offer in offers) {
      final section = (offer.section == null || offer.section!.isEmpty)
          ? 'Ce qu\'on y trouve'
          : offer.section!;
      grouped.putIfAbsent(section, () => []).add(offer);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    // Rien à montrer : la section disparaît plutôt que d'annoncer un
    // catalogue inexistant.
    if (offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in _bySection.entries) ...[
          // Le carrousel gère son propre titre et sa propre hauteur : c'est
          // le même composant que sur l'accueil, pour que le catalogue s'y
          // lise exactement pareil.
          OffersCarouselSection(title: entry.key, offers: entry.value),
          AppDimens.spacerMedium,
        ],
      ],
    );
  }
}
